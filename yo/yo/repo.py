"""The configuration repository as yo sees it.

Everything here is read from three places:

* the catalogue (lib/catalog.nix), a few milliseconds of Nix that lists the
  packages, sets and profiles in the working tree;
* /etc/yo/state.json, which the running system publishes about itself;
* an evaluation of the working tree, when what the tree *would* build has to
  be known exactly. That takes a while, so it is cached per tree content.
"""

from __future__ import annotations

import hashlib
import json
import os
import subprocess
import time
from dataclasses import dataclass
from functools import cached_property
from pathlib import Path

RUNNING_STATE = Path("/etc/yo/state.json")


class YoError(Exception):
    """Something the user should be told plainly, without a traceback."""


def config_dir() -> Path:
    return Path(os.environ.get("XDG_CONFIG_HOME") or Path.home() / ".config") / "yo"


def state_dir() -> Path:
    return Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state") / "yo"


def cache_dir() -> Path:
    return Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache") / "yo"


def nix_cache_dir() -> Path:
    """Where Nix, run as this user, keeps its caches."""
    return Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache") / "nix"


def foreign_cache_entries(uid: int | None = None) -> list[Path]:
    """Parts of Nix's cache that belong to someone else, usually root.

    That happens when root's Nix is pointed at this user's cache (sudo with
    XDG_CACHE_HOME set). Nix run as the user then cannot write there and fails
    with "Permission denied". Only the places Nix writes to on every run are
    looked at, which is enough to tell and takes no time.
    """
    uid = os.getuid() if uid is None else uid
    base = nix_cache_dir()
    found: list[Path] = []
    try:
        candidates = [base, *sorted(base.iterdir())]
        for name in ("eval-cache-v6", "fetcher-locks"):
            folder = base / name
            if folder.is_dir():
                try:
                    candidates.extend(sorted(folder.iterdir())[:400])
                except OSError:
                    pass
        for path in candidates:
            try:
                if path.lstat().st_uid != uid:
                    found.append(path)
            except OSError:
                continue
    except OSError:
        return []
    return found


CACHE_PROBLEM = (
    "Parts of Nix's cache ({directory}) belong to root, so Nix cannot use it when it runs as you.\n"
    "sudo left them there: root's Nix was pointed at your cache directory."
)


def read_json(path: Path, default=None):
    try:
        return json.loads(path.read_text())
    except (OSError, ValueError):
        return default


def write_json(path: Path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    temporary.write_text(json.dumps(value, indent=2) + "\n")
    temporary.replace(path)


def is_repo(path: Path) -> bool:
    return (path / "flake.nix").is_file() and (path / "lib/catalog.nix").is_file()


def find_root(explicit: str | None = None) -> Path:
    """Where the configuration lives."""
    candidates = []
    if explicit:
        candidates.append(Path(explicit))
    for variable in ("YO_ROOT", "DOTFILES_TOP"):
        if os.environ.get(variable):
            candidates.append(Path(os.environ[variable]))
    here = Path.cwd()
    candidates.extend([here, *here.parents])
    running = read_json(RUNNING_STATE, {})
    if running.get("root"):
        candidates.append(Path(running["root"]))
    remembered = read_json(config_dir() / "config.json", {})
    if remembered.get("root"):
        candidates.append(Path(remembered["root"]))
    for candidate in candidates:
        candidate = candidate.expanduser()
        if is_repo(candidate):
            return candidate.resolve()
    if explicit:
        raise YoError(f"{explicit} is not a yo configuration (no flake.nix with lib/catalog.nix)")
    raise YoError(
        "Could not find the configuration. Run yo from inside it, pass --root, "
        "or set YO_ROOT.")


@dataclass(frozen=True)
class ProfileRef:
    user: str
    machine: str

    @property
    def name(self) -> str:
        return f"{self.user}-{self.machine}"


class Repo:
    def __init__(self, root: Path):
        self.root = root

    # ---------------------------------------------------------------- catalogue

    @cached_property
    def catalog(self) -> dict:
        result = subprocess.run(
            ["nix-instantiate", "--eval", "--strict", "--json",
             "--arg", "root", str(self.root), str(self.root / "lib/catalog.nix")],
            capture_output=True, text=True,
        )
        if result.returncode != 0:
            raise YoError("The configuration could not be read:\n" + result.stderr.strip())
        return json.loads(result.stdout)

    def reload(self):
        self.__dict__.pop("catalog", None)
        self.__dict__.pop("fingerprint", None)

    @property
    def packages(self) -> dict:
        return self.catalog["packages"]

    @property
    def sets(self) -> dict:
        return self.catalog["sets"]

    def profiles(self) -> list[ProfileRef]:
        return [
            ProfileRef(user, machine)
            for user, entry in sorted(self.catalog["profiles"].items())
            for machine in sorted(entry["machines"])
        ]

    def profile_entry(self, ref: ProfileRef, shared: bool = False) -> dict:
        user = self.catalog["profiles"][ref.user]
        return user if shared else user["machines"][ref.machine]

    def profile_file(self, ref: ProfileRef, shared: bool = False) -> Path:
        """The profile.nix of a machine, or of its user when `shared`."""
        directory = self.root / self.profile_entry(ref, shared)["dir"]
        return directory / "profile.nix"

    def set_file(self, name: str) -> Path:
        return self.root / self.sets[name]["file"]

    # ------------------------------------------------------------- which profile

    def resolve_profile(self, explicit: str | None = None) -> ProfileRef:
        known = self.profiles()
        by_name = {ref.name: ref for ref in known}

        def lookup(name, origin):
            if name in by_name:
                return by_name[name]
            raise YoError(
                f"There is no profile {name!r} ({origin}). Known profiles: "
                + (", ".join(sorted(by_name)) or "none"))

        if explicit:
            return lookup(explicit, "given on the command line")
        if os.environ.get("YO_PROFILE"):
            return lookup(os.environ["YO_PROFILE"], "from YO_PROFILE")
        running = self.running_state()
        if running and running.get("profile", {}).get("name") in by_name:
            return by_name[running["profile"]["name"]]
        remembered = read_json(config_dir() / "config.json", {}).get("profile")
        if remembered in by_name:
            return by_name[remembered]
        if len(known) == 1:
            return known[0]
        detected = self.detect_profile()
        if detected is not None:
            return detected
        if not known:
            raise YoError("There are no profiles yet. Create one with: yo init")
        raise YoError(
            "Which profile is this machine? Tell yo once with: yo hop <profile>\n"
            "Known profiles: " + ", ".join(sorted(by_name)))

    def detect_profile(self) -> ProfileRef | None:
        """The one profile whose hardware configuration describes this machine.

        A machine is recognised by its disks: the UUIDs of its file systems
        are written into the hardware-configuration.nix generated on it.
        """
        import re
        try:
            present = set(os.listdir("/dev/disk/by-uuid"))
        except OSError:
            return None
        matches = []
        for ref in self.profiles():
            hardware = self.root / self.profile_entry(ref)["dir"] / "hardware-configuration.nix"
            try:
                wanted = set(re.findall(r"/dev/disk/by-uuid/([0-9A-Za-z-]+)", hardware.read_text()))
            except OSError:
                continue
            if wanted and wanted <= present:
                matches.append(ref)
        return matches[0] if len(matches) == 1 else None

    def remember_profile(self, ref: ProfileRef):
        path = config_dir() / "config.json"
        config = read_json(path, {})
        config.update({"profile": ref.name, "root": str(self.root)})
        write_json(path, config)

    # --------------------------------------------------------------------- state

    def running_state(self) -> dict | None:
        """What the running system says about itself, if yo built it."""
        return read_json(RUNNING_STATE)

    @cached_property
    def fingerprint(self) -> str:
        """A hash of everything in the tree that can influence a build."""
        digest = hashlib.sha256()

        def walk(directory: Path, prefix: str):
            for name in sorted(os.listdir(directory), key=lambda entry: entry.encode()):
                if name.startswith(".") or name.startswith("result") or name == "__pycache__":
                    continue
                path = directory / name
                relative = prefix + name
                if path.is_symlink():
                    continue
                if path.is_dir():
                    walk(path, relative + "/")
                elif path.is_file() and not name.endswith((".md", ".pyc")):
                    content = hashlib.sha256(path.read_bytes()).hexdigest()
                    digest.update(f"{relative} {content}\n".encode())

        walk(self.root, "")
        return digest.hexdigest()

    def applied(self) -> dict:
        """What yo last switched this machine to."""
        return read_json(state_dir() / "applied.json", {})

    def record_applied(self, ref: ProfileRef, system: str):
        write_json(state_dir() / "applied.json", {
            "profile": ref.name,
            "fingerprint": self.fingerprint,
            "system": system,
            "time": time.time(),
        })

    def in_sync(self) -> bool | None:
        """Is the running system built from the tree as it is now?

        None when that is not known, because the system was not switched with yo.
        """
        applied = self.applied()
        if not applied:
            return None
        try:
            current = os.path.realpath("/run/current-system")
        except OSError:
            return None
        if applied.get("system") != current:
            return None
        return applied.get("fingerprint") == self.fingerprint

    def flake_ref(self, ref: ProfileRef, attribute: str) -> str:
        return f"path:{self.root}#nixosConfigurations.{ref.name}.{attribute}"

    def evaluated_state(self, ref: ProfileRef, refresh: bool = False, quiet: bool = False) -> dict:
        """What the working tree would build for `ref` (slow; cached per tree content)."""
        cache = cache_dir() / f"state-{ref.name}-{self.fingerprint[:24]}.json"
        if not refresh:
            cached = read_json(cache)
            if cached is not None:
                return cached
        result = subprocess.run(
            ["nix", "eval", "--json", self.flake_ref(ref, "config.yo.state")],
            capture_output=True, text=True,
        )
        if result.returncode != 0:
            if "Permission denied" in result.stderr and str(nix_cache_dir()) in result.stderr:
                raise YoError(CACHE_PROBLEM.format(directory=nix_cache_dir()) + "\nRepair it with: yo doctor --fix")
            raise YoError("The configuration does not evaluate:\n" + _tail(result.stderr))
        state = json.loads(result.stdout)
        for stale in cache_dir().glob(f"state-{ref.name}-*.json"):
            stale.unlink(missing_ok=True)
        write_json(cache, state)
        return state

    def best_state(self, ref: ProfileRef) -> tuple[dict | None, str]:
        """The best knowledge of the profile's state that is available instantly.

        Returns (state, origin) with origin "tree" (exact for the working
        tree), "running" (the running system, which the tree may have moved
        on from) or "none".
        """
        cached = read_json(cache_dir() / f"state-{ref.name}-{self.fingerprint[:24]}.json")
        if cached is not None:
            return cached, "tree"
        running = self.running_state()
        if running and running.get("profile", {}).get("name") == ref.name:
            return running, "tree" if self.in_sync() else "running"
        return None, "none"

    # ---------------------------------------------------------------- flake lock

    def flake_inputs(self) -> dict:
        """The flake's direct inputs: { name: locked node }."""
        lock = read_json(self.root / "flake.lock", {})
        nodes = lock.get("nodes", {})
        result = {}
        for name, node in sorted(nodes.get("root", {}).get("inputs", {}).items()):
            if isinstance(node, str) and node in nodes:
                result[name] = nodes[node]
        return result


def _tail(text: str, lines: int = 25) -> str:
    """The part of Nix's error output that says what is wrong."""
    kept = [line for line in text.strip().splitlines()
            if not line.startswith(("unpacking ", "copying ", "warning: Git tree"))]
    # The message proper starts at the last line that begins with "error:".
    starts = [index for index, line in enumerate(kept) if line.lstrip().startswith("error:")]
    if starts:
        message = kept[starts[-1]:]
        # Say which file the trace last went through, when it is one of ours.
        ours = [line.strip() for line in kept[:starts[-1]]
                if "while evaluating definitions from" in line and "-source/" in line]
        context = [ours[-1]] if ours else []
        return "\n".join(context + [line.rstrip() for line in message][:12])
    return "\n".join(kept[-lines:])


# ------------------------------------------------------------------ selection


def static_selection(repo: Repo, ref: ProfileRef) -> dict:
    """What can be said about a profile without evaluating it.

    Follows the profile data and the data sets only; sets written as modules
    contribute what they like, which only an evaluation can tell.

    Returns {"sets": {name: origin}, "packages": {name: {variant: [origins]}},
    "exclude": {name: [variants]}}.
    """
    user = repo.profile_entry(ref, shared=True)
    machine = repo.profile_entry(ref)
    layers = [
        ("your shared profile", (user.get("data") or {}).get("value") or {}),
        (f"the {ref.machine} profile", (machine.get("data") or {}).get("value") or {}),
    ]

    enabled: dict[str, str] = {}
    disabled: set[str] = set()

    def flags(tree, prefix=()):
        for key, value in tree.items():
            if isinstance(value, dict):
                yield from flags(value, prefix + (key,))
            elif key == "enable" and isinstance(value, bool):
                yield ".".join(prefix), value

    explicit: dict[str, tuple[bool, str]] = {}
    for origin, data in layers:
        for name, value in flags(data.get("modules", {})):
            explicit[name] = (value, origin)

    for name, entry in repo.sets.items():
        if name in explicit:
            value, origin = explicit[name]
            if value:
                enabled[name] = origin
            else:
                disabled.add(name)
        elif entry.get("default"):
            enabled[name] = "on by default"

    # Sets switched on by other (data) sets, unless the profile says otherwise.
    changed = True
    while changed:
        changed = False
        for name in list(enabled):
            for member in repo.sets.get(name, {}).get("sets", []):
                if member not in enabled and member not in disabled:
                    enabled[member] = f"set {name}"
                    changed = True

    packages: dict[str, dict[str, list[str]]] = {}

    def select(selection, origin):
        for package, variants in selection.items():
            for variant in variants:
                packages.setdefault(package, {}).setdefault(variant, []).append(origin)

    for name in sorted(enabled):
        select(repo.sets.get(name, {}).get("packages", {}), f"set {name}")
    exclude: dict[str, list[str]] = {}
    for origin, data in layers:
        select(data.get("packages", {}), origin)
        for package, variants in data.get("exclude", {}).items():
            exclude.setdefault(package, []).extend(variants)

    return {"sets": enabled, "packages": packages, "exclude": exclude}
