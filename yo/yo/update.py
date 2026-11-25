"""Keeping pinned versions current.

A package says in its meta.nix what it pins and how to refresh it:

    inputs = [ "codex-cli" ];          # flake inputs the package owns

    update = {                          # a pin kept in a file next to meta.nix
      type = "github-release";
      repo = "owner/name";
      file = "release.json";
      assets = { <system> = { <name> = [ "<asset file name>" ... ]; }; };
    };

    update = { type = "command"; run = [ "./update.sh" ]; };   # anything else

Flake inputs no package claims (nixpkgs, home-manager, ...) belong to the
system as a whole and are updated with the rest.

An update only rewrites files (flake.lock and the pin files). What they held
before is remembered, so that an update which turns out not to build can be
taken back: see `undo`.
"""

from __future__ import annotations

import hashlib
import json
import re
import subprocess
import time
import urllib.error
import urllib.request
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

from .repo import Repo, YoError, read_json, state_dir, write_json

USER_AGENT = "yo-updater"


@dataclass
class Target:
    """One thing that can be checked and updated."""

    name: str                 # what the user calls it: a package or a flake input
    kind: str                 # "input" or "pin"
    owner: str | None = None  # the package that owns it, if any
    spec: dict = field(default_factory=dict)
    directory: Path | None = None

    @property
    def label(self) -> str:
        if self.kind == "input":
            return f"{self.name} (flake input" + (f" of {self.owner})" if self.owner else ")")
        return f"{self.name} ({self.spec.get('type', 'pin')})"


@dataclass
class Status:
    target: Target
    current: str = ""
    latest: str = ""
    outdated: bool | None = None  # None: could not tell
    note: str = ""


def targets(repo: Repo) -> list[Target]:
    """Everything updatable, package-owned things first."""
    found: list[Target] = []
    inputs = repo.flake_inputs()
    claimed: set[str] = set()
    for name, package in sorted(repo.packages.items()):
        meta = package.get("meta") or {}
        directory = repo.root / "src" / name
        for flake_input in meta.get("inputs", []):
            if flake_input not in inputs:
                raise YoError(f"src/{name}/meta.nix names the flake input {flake_input!r}, which flake.nix does not have")
            claimed.add(flake_input)
            found.append(Target(flake_input, "input", owner=name))
        specs = meta.get("update")
        if isinstance(specs, dict):
            specs = [specs]
        for spec in specs or []:
            found.append(Target(name, "pin", owner=name, spec=spec, directory=directory))
    for name in inputs:
        if name not in claimed:
            found.append(Target(name, "input"))
    return found


def select(repo: Repo, names: list[str]) -> list[Target]:
    """The targets the given package or input names stand for; all of them without names."""
    everything = targets(repo)
    if not names:
        return everything
    chosen: list[Target] = []
    for name in names:
        matching = [target for target in everything if name in (target.name, target.owner)]
        if not matching:
            known = sorted({target.owner or target.name for target in everything})
            raise YoError(f"Nothing called {name!r} can be updated. Updatable: {', '.join(known)}")
        chosen.extend(target for target in matching if target not in chosen)
    return chosen


# ------------------------------------------------------------- flake inputs


def _date(timestamp) -> str:
    try:
        return datetime.fromtimestamp(int(timestamp), timezone.utc).strftime("%Y-%m-%d")
    except (TypeError, ValueError):
        return "?"


def _remote_url(node: dict) -> tuple[str, str | None] | None:
    """The git URL and ref of a flake input, when it has one."""
    original = node.get("original", {})
    locked = node.get("locked", {})
    kind = locked.get("type") or original.get("type")
    ref = original.get("ref")
    if kind == "github":
        return f"https://github.com/{locked.get('owner')}/{locked.get('repo')}", ref
    if kind == "gitlab":
        host = locked.get("host", "gitlab.com")
        return f"https://{host}/{locked.get('owner')}/{locked.get('repo')}", ref
    if kind == "git":
        return locked.get("url") or original.get("url"), ref
    return None


def check_input(repo: Repo, target: Target) -> Status:
    node = repo.flake_inputs()[target.name]
    locked = node.get("locked", {})
    revision = locked.get("rev", "")
    status = Status(target, current=f"{revision[:10]} ({_date(locked.get('lastModified'))})")
    remote = _remote_url(node)
    if remote is None or not revision:
        status.note = "not a git input"
        return status
    url, ref = remote
    try:
        result = subprocess.run(
            ["git", "ls-remote", url, ref or "HEAD"],
            capture_output=True, text=True, timeout=30,
        )
    except (OSError, subprocess.TimeoutExpired) as error:
        status.note = f"could not reach {url} ({error.__class__.__name__})"
        return status
    lines = [line.split() for line in result.stdout.splitlines() if line.strip()]
    if result.returncode != 0 or not lines:
        status.note = f"could not reach {url}"
        return status
    # Prefer the branch when a tag of the same name exists.
    head = next((sha for sha, name in lines if name in ("HEAD", f"refs/heads/{ref}")), lines[0][0])
    status.latest = head[:10]
    status.outdated = head != revision
    return status


def update_inputs(repo: Repo, names: list[str]) -> list[str]:
    """Update flake inputs (all of them when `names` is empty). Returns what changed."""
    before = {name: node.get("locked", {}).get("rev") for name, node in repo.flake_inputs().items()}
    command = ["nix", "flake", "update", *names, "--flake", f"path:{repo.root}"]
    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        raise YoError("Updating flake inputs failed:\n" + result.stderr.strip()[-2000:])
    changed = []
    for name, node in repo.flake_inputs().items():
        revision = node.get("locked", {}).get("rev")
        if revision != before.get(name):
            changed.append(f"{name}: {(before.get(name) or 'new')[:10]} -> {(revision or '?')[:10]} "
                           f"({_date(node.get('locked', {}).get('lastModified'))})")
    return changed


# ---------------------------------------------------------- GitHub releases


def _get(url: str, accept: str = "application/vnd.github+json"):
    request = urllib.request.Request(url, headers={
        "Accept": accept,
        "User-Agent": USER_AGENT,
        "X-GitHub-Api-Version": "2022-11-28",
    })
    return urllib.request.urlopen(request, timeout=60)


def _latest_release(repository: str) -> dict:
    try:
        with _get(f"https://api.github.com/repos/{repository}/releases/latest") as response:
            release = json.load(response)
    except (urllib.error.URLError, OSError, ValueError) as error:
        raise YoError(f"Could not ask GitHub for the latest release of {repository}: {error}")
    if not isinstance(release, dict) or release.get("draft") is not False or release.get("prerelease") is not False:
        raise YoError(f"The latest release of {repository} is not a published stable release")
    return release


def _release_version(release: dict, repository: str) -> str:
    tag = release.get("tag_name")
    match = re.fullmatch(r"v?((?:0|[1-9][0-9]*)(?:\.(?:0|[1-9][0-9]*)){1,3})", tag) if isinstance(tag, str) else None
    if match is None:
        raise YoError(f"{repository}: expected a release tag like v1.2.3, got {tag!r}")
    return match.group(1)


def _sha256(asset: dict) -> str:
    digest = asset.get("digest")
    match = re.fullmatch(r"sha256:([0-9a-fA-F]{64})", digest) if isinstance(digest, str) else None
    if match:
        return match.group(1).lower()
    # Older releases carry no digest: fetch the file and hash it.
    hasher = hashlib.sha256()
    with _get(asset["browser_download_url"], accept="application/octet-stream") as response:
        for chunk in iter(lambda: response.read(1 << 20), b""):
            hasher.update(chunk)
    return hasher.hexdigest()


def resolve_release(spec: dict) -> dict:
    """The content of a pin file for the latest release named by `spec`."""
    repository = spec["repo"]
    release = _latest_release(repository)
    version = _release_version(release, repository)
    tag = release["tag_name"]
    assets = release.get("assets")
    if not isinstance(assets, list):
        raise YoError(f"{repository}: GitHub returned no asset list")
    systems = {}
    for system, wanted in spec.get("assets", {}).items():
        systems[system] = {}
        for kind, candidates in wanted.items():
            if isinstance(candidates, str):
                candidates = [candidates]
            names = [candidate.replace("{version}", version) for candidate in candidates]
            matches = [asset for asset in assets if isinstance(asset, dict) and asset.get("name") in names]
            if len(matches) != 1:
                raise YoError(
                    f"{repository} {tag}: expected exactly one asset named "
                    + " or ".join(names) + f", found {len(matches)}")
            asset = matches[0]
            if asset.get("state") != "uploaded":
                raise YoError(f"{repository} {tag}: the asset {asset['name']} is not fully uploaded")
            url = f"https://github.com/{repository}/releases/download/{tag}/{asset['name']}"
            if asset.get("browser_download_url") != url:
                raise YoError(f"{repository} {tag}: the asset {asset['name']} has an unexpected download URL")
            systems[system][kind] = {"url": url, "sha256": _sha256(asset)}
    return {"version": version, "systems": systems}


def _pin_file(target: Target) -> Path:
    return target.directory / target.spec.get("file", "release.json")


def check_release(target: Target) -> Status:
    current = (json.loads(_pin_file(target).read_text()) if _pin_file(target).exists() else {}).get("version", "")
    status = Status(target, current=current)
    release = _latest_release(target.spec["repo"])
    status.latest = _release_version(release, target.spec["repo"])
    status.outdated = status.latest != current
    return status


def update_release(target: Target) -> str | None:
    """Rewrite the pin file for the latest release. Returns a description if it changed."""
    path = _pin_file(target)
    old = path.read_text() if path.exists() else ""
    metadata = resolve_release(target.spec)
    new = json.dumps(metadata, indent=2) + "\n"
    if new == old:
        return None
    temporary = path.with_name(f".{path.name}.yo-tmp")
    temporary.write_text(new)
    temporary.replace(path)
    previous = ""
    try:
        previous = json.loads(old).get("version", "")
    except ValueError:
        pass
    return f"{target.name}: {previous or 'unpinned'} -> {metadata['version']}"


# ----------------------------------------------------------- custom commands


def update_command(target: Target) -> str | None:
    command = target.spec.get("run")
    if isinstance(command, str):
        command = ["sh", "-c", command]
    if not command:
        raise YoError(f"src/{target.name}/meta.nix: a command updater needs `run`")
    result = subprocess.run(command, cwd=target.directory, capture_output=True, text=True)
    if result.returncode != 0:
        raise YoError(f"The updater of {target.name} failed:\n" + (result.stderr or result.stdout).strip()[-2000:])
    output = (result.stdout or "").strip().splitlines()
    return f"{target.name}: {output[-1]}" if output else f"{target.name}: updater ran"


# -------------------------------------------------------------------- facade


def check(repo: Repo, target: Target) -> Status:
    try:
        if target.kind == "input":
            return check_input(repo, target)
        if target.spec.get("type") == "github-release":
            return check_release(target)
        return Status(target, note="runs a custom command; cannot be checked without running it")
    except YoError as error:
        return Status(target, note=str(error))


def update(repo: Repo, chosen: list[Target], everything: bool) -> list[str]:
    """Run the updaters. Returns one line per thing that changed."""
    changes: list[str] = []
    earlier = pending(repo)
    before = _contents(_watched(repo, chosen))
    try:
        inputs = [target.name for target in chosen if target.kind == "input"]
        if everything:
            changes += update_inputs(repo, [])
        elif inputs:
            changes += update_inputs(repo, inputs)
        for target in chosen:
            if target.kind != "pin":
                continue
            kind = target.spec.get("type")
            if kind == "github-release":
                change = update_release(target)
            elif kind == "command":
                change = update_command(target)
            else:
                raise YoError(f"src/{target.name}/meta.nix: unknown updater type {kind!r}")
            if change:
                changes.append(change)
    finally:
        # Also when an updater failed: the ones before it have already written.
        _remember(repo, chosen, before, changes, earlier)
    return changes


# ------------------------------------------------------------- taking it back


def _record_file() -> Path:
    return state_dir() / "last-update.json"


def _digest(text: str | None) -> str | None:
    return None if text is None else hashlib.sha256(text.encode()).hexdigest()


def _watched(repo: Repo, chosen: list[Target]) -> list[Path]:
    """The files that updating `chosen` may rewrite."""
    files = [repo.root / "flake.lock"]
    for target in chosen:
        if target.kind != "pin" or target.directory is None:
            continue
        if target.spec.get("type") == "command":
            # A command may write anything; what it keeps lives next to its meta.nix.
            files += sorted(path for path in target.directory.rglob("*")
                            if path.is_file() and not path.is_symlink())
        else:
            files.append(_pin_file(target))
    return list(dict.fromkeys(files))


def _contents(paths) -> dict[Path, str | None]:
    """The text of each file, None for one that does not exist."""
    found: dict[Path, str | None] = {}
    for path in paths:
        try:
            found[path] = path.read_text() if path.exists() else None
        except (OSError, UnicodeDecodeError):
            continue    # not text: it could not be put back, so it is left alone
    return found


def _remember(repo: Repo, chosen: list[Target], before: dict, changes: list[str], earlier: dict | None):
    """Record what the files held before, on top of updates that were never applied."""
    now = _contents(dict.fromkeys([*before, *_watched(repo, chosen)]))
    files = dict(earlier["files"]) if earlier else {}
    for path, text in now.items():
        relative = str(path.relative_to(repo.root))
        if relative in files:
            # Already changed by an earlier update: keep what it held before that one.
            files[relative] = {"before": files[relative]["before"], "after": _digest(text)}
        elif text != before.get(path):
            files[relative] = {"before": before.get(path), "after": _digest(text)}
    files = {relative: entry for relative, entry in files.items() if _digest(entry["before"]) != entry["after"]}
    if not files:
        if earlier:
            _record_file().unlink(missing_ok=True)   # everything is back where it started
        return
    moment = time.time()
    write_json(_record_file(), {
        "root": str(repo.root),
        "since": earlier["since"] if earlier else moment,
        "time": moment,
        "changes": (earlier["changes"] if earlier else []) + list(changes),
        "files": files,
    })


def last_update(repo: Repo) -> dict | None:
    """The record of the latest update, while the files are still as it left them."""
    record = read_json(_record_file())
    if not isinstance(record, dict) or record.get("root") != str(repo.root) or not record.get("files"):
        return None
    for relative, entry in record["files"].items():
        path = repo.root / relative
        now = _contents([path])
        if path not in now or _digest(now[path]) != entry["after"]:
            return None
    return record


def pending(repo: Repo) -> dict | None:
    """The latest update, if no system was applied since it was made.

    A build that fails while an update is pending most likely fails because
    of it; once a system with the update has been applied, it has proven itself.
    """
    record = last_update(repo)
    if record is None:
        return None
    applied = repo.applied().get("time")
    if applied is None:
        try:
            applied = (state_dir() / "applied.json").stat().st_mtime
        except OSError:
            applied = 0
    return record if record.get("time", 0) > applied else None


def when(record: dict) -> str:
    """When an update was made, as one says it: the time, with the day if it was not today."""
    moment = datetime.fromtimestamp(record.get("time", 0))
    if moment.date() == datetime.now().date():
        return moment.strftime("%H:%M")
    return moment.strftime("%Y-%m-%d %H:%M")


def undo(repo: Repo) -> list[str]:
    """Put the files back as they were before the latest update. Returns their names."""
    record = read_json(_record_file())
    if not isinstance(record, dict) or record.get("root") != str(repo.root) or not record.get("files"):
        raise YoError("No update of this configuration is on record, so there is nothing to take back")
    if last_update(repo) is None:
        raise YoError("These files changed again after the update, so it cannot be taken back automatically: "
                      + ", ".join(sorted(record["files"])))
    for relative, entry in record["files"].items():
        path = repo.root / relative
        if entry["before"] is None:
            path.unlink(missing_ok=True)
        else:
            path.write_text(entry["before"])
    _record_file().unlink(missing_ok=True)
    return sorted(record["files"])
