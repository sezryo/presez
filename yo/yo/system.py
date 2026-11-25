"""Building the configuration and changing the running system."""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import threading
from dataclasses import dataclass
from pathlib import Path

from .failure import Failed, Failure, clean, explain
from .repo import ProfileRef, Repo, YoError

CURRENT_SYSTEM = Path("/run/current-system")


def run(command: list[str], *, on_line=None, cwd: Path | None = None, env: dict | None = None) -> int:
    """Run a command, passing its output through line by line."""
    if on_line is None:
        return subprocess.run(command, cwd=cwd, env=env).returncode
    process = subprocess.Popen(
        command, cwd=cwd, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        text=True, errors="replace", bufsize=1,
    )
    assert process.stdout is not None
    for line in process.stdout:
        on_line(line.rstrip("\n"))
    return process.wait()


def _no_new_privileges() -> bool:
    try:
        for line in Path("/proc/self/status").read_text().splitlines():
            if line.startswith("NoNewPrivs:"):
                return line.split()[1] == "1"
    except OSError:
        pass
    return False


# Where a user's programs keep their files. Root must not inherit these: it
# would write its own caches and state into the user's home, as root.
USER_DIRECTORIES = ("XDG_CACHE_HOME", "XDG_STATE_HOME", "XDG_DATA_HOME", "XDG_CONFIG_HOME")


def elevate(command: list[str], graphical: bool = False) -> list[str]:
    """`command`, wrapped so that it runs as root, in root's own directories."""
    if os.geteuid() == 0:
        return command
    env = shutil.which("env") or "/run/current-system/sw/bin/env"
    command = [env, *(part for name in USER_DIRECTORIES for part in ("-u", name)), *command]
    sudo = shutil.which("sudo") or "/run/wrappers/bin/sudo"
    if _no_new_privileges():
        # Inside a sandbox that forbids gaining privileges (some app launchers
        # do this) sudo cannot work, so hand the command to the user's own
        # service manager, which runs outside of it.
        runner = shutil.which("systemd-run")
        if runner:
            return [runner, "--user", "--wait", "--pipe", "--quiet", "--collect", sudo, "-n", *command]
    passwordless = subprocess.run([sudo, "-n", "true"], capture_output=True).returncode == 0
    if passwordless:
        return [sudo, "-n", *command]
    if graphical:
        pkexec = shutil.which("pkexec")
        if pkexec:
            return [pkexec, *command]
    return [sudo, *command]


def as_root(step: list[str], title: str, summary: str, *, on_line=None, graphical: bool = False) -> None:
    """Run `step` as root. A failure says `title` and `summary`, and what the command printed."""
    command = elevate(step, graphical=graphical)
    if on_line is None:
        code, lines = run(command), []
    else:
        lines = []

        def collect(line: str):
            lines.append(line)
            on_line(line)

        code = run(command, on_line=collect)
    if code == 0:
        return
    printed = [line for line in clean("\n".join(lines)) if line.strip()]
    failure = Failure(
        phase="activate", title=title, summary=f"{summary} (exit status {code}).",
        message="\n".join(printed[-25:]), log="\n".join(printed))
    if os.path.basename(command[0]) == "pkexec" and code in (126, 127):
        # 126: the dialog was dismissed; 127: the password was wrong or not allowed.
        failure.phase = "denied"
        failure.title = "Not Authorised"
        failure.summary = "The request for administrator rights was dismissed or refused, so nothing was changed."
        failure.message = ""
    elif _no_new_privileges() and (not printed or any(
            "password" in line or "no new privileges" in line.lower() for line in printed)):
        failure.advice.append("This program runs in a sandbox that cannot ask for a password. "
                              "Run it from a regular terminal, or allow sudo without a password.")
    raise Failed(failure)


def repair_cache(*, on_line=None, graphical: bool = False) -> None:
    """Give Nix's cache back to the user it belongs to."""
    from .repo import nix_cache_dir
    chown = shutil.which("chown") or "/run/current-system/sw/bin/chown"
    owner = f"{os.getuid()}:{os.getgid()}"
    as_root([chown, "-R", owner, str(nix_cache_dir())],
            "Repairing the Cache Failed", "Nix's cache could not be handed back",
            on_line=on_line, graphical=graphical)


# --------------------------------------------------------------------- build


def build(repo: Repo, ref: ProfileRef, *, on_line=None, show_trace: bool = False) -> str:
    """Build the profile's system. Returns its store path."""
    command = [
        "nix", "build", "--no-link", "--print-out-paths",
        repo.flake_ref(ref, "config.system.build.toplevel"),
    ]
    if show_trace:
        command.append("--show-trace")
    lines: list[str] = []

    def collect(line: str):
        lines.append(line)
        if on_line is not None and not line.startswith("/nix/store/"):
            on_line(line)

    process = subprocess.Popen(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, errors="replace", bufsize=1)
    # Progress goes to stderr, the result to stdout.
    assert process.stderr is not None and process.stdout is not None

    def pump():
        for line in process.stderr:
            collect(line.rstrip("\n"))

    reader = threading.Thread(target=pump, daemon=True)
    reader.start()
    output = process.stdout.read()
    code = process.wait()
    reader.join()
    if code != 0:
        raise Failed(explain("\n".join(lines), repo.root, ref.name))
    paths = [line for line in output.splitlines() if line.startswith("/nix/store/")]
    if not paths:
        raise YoError("The build finished without producing a system")
    return paths[-1]


def build_log(derivation: str, limit: int = 4000) -> str:
    """What the builder of `derivation` printed, as Nix kept it."""
    if not re.fullmatch(r"/nix/store/[0-9a-z]{32}-[^/\s]+\.drv", derivation):
        raise YoError(f"Not a derivation: {derivation}")
    result = subprocess.run(["nix", "log", derivation], capture_output=True, text=True, errors="replace")
    if result.returncode != 0:
        raise YoError("The log could not be read:\n" + result.stderr.strip()[-1500:])
    lines = clean(result.stdout)
    if len(lines) > limit:
        lines = [f"(the last {limit} of {len(lines)} lines)", "", *lines[-limit:]]
    return "\n".join(lines)


@dataclass
class Change:
    name: str
    old: str
    new: str

    @property
    def kind(self) -> str:
        if not self.old:
            return "added"
        if not self.new:
            return "removed"
        return "changed"


def closure_diff(old: str, new: str) -> list[Change]:
    """Package-level differences between two systems."""
    if os.path.realpath(old) == os.path.realpath(new):
        return []
    result = subprocess.run(
        ["nix", "store", "diff-closures", old, new], capture_output=True, text=True)
    if result.returncode != 0:
        raise YoError("Could not compare the systems:\n" + result.stderr.strip()[-1500:])
    return parse_closure_diff(result.stdout)


_SIZE = re.compile(r"[+-]?[0-9]+(\.[0-9]+)? (B|KiB|MiB|GiB|TiB)")


def parse_closure_diff(text: str) -> list[Change]:
    """Read the output of `nix store diff-closures`.

    Lines look like `name: 1.0 → 1.1, +12.3 KiB`, where a side is `∅` when the
    package is absent and `ε` when it has no version.
    """
    changes = []
    for line in text.splitlines():
        line = re.sub(r"\x1b\[[0-9;]*m", "", line).strip()
        name, separator, rest = line.partition(": ")
        if not separator:
            continue
        parts = [part.strip() for part in rest.split(",")]
        if parts and _SIZE.fullmatch(parts[-1]):
            parts.pop()
        rest = ", ".join(parts)
        if "→" not in rest:
            # Same version on both sides, only its size differs: a rebuild.
            changes.append(Change(name.strip(), "rebuilt", "rebuilt"))
            continue
        old, new = (side.strip() for side in rest.split("→", 1))

        def version(side: str) -> str:
            if side == "∅":
                return ""
            return "unversioned" if side == "ε" else side

        changes.append(Change(name.strip(), version(old), version(new)))
    return changes


def current_system() -> str | None:
    try:
        return os.path.realpath(CURRENT_SYSTEM)
    except OSError:
        return None


# ------------------------------------------------------------------ activate


def _rebuild() -> str:
    return shutil.which("nixos-rebuild") or "/run/current-system/sw/bin/nixos-rebuild"


def _takes_store_path(rebuild: str) -> bool:
    try:
        return "--store-path" in subprocess.run([rebuild, "--help"], capture_output=True, text=True).stdout
    except OSError:
        return False


def activate(system: str, action: str = "switch", *, on_line=None, graphical: bool = False) -> None:
    """Make an already built system the running one (`switch`), the next one
    to boot (`boot`), or try it without making it permanent (`test`)."""
    rebuild = _rebuild()
    if _takes_store_path(rebuild):
        steps = [[rebuild, action, "--store-path", system]]
    else:
        # Older nixos-rebuild: register the system and activate it by hand.
        steps = [[f"{system}/bin/switch-to-configuration", action]]
        if action in ("switch", "boot"):
            steps.insert(0, ["nix-env", "--profile", "/nix/var/nix/profiles/system", "--set", system])
    for step in steps:
        try:
            as_root(step, "The Switch Did Not Finish",
                    "The new system is built, but switching to it ended with an error",
                    on_line=on_line, graphical=graphical)
        except Failed as error:
            if error.failure.phase != "denied":
                error.failure.advice.append("The previous system is still there: yo rollback")
            raise


def rollback(*, on_line=None, graphical: bool = False) -> None:
    as_root([_rebuild(), "switch", "--rollback"],
            "Rolling Back Failed", "Going back to the previous generation ended with an error",
            on_line=on_line, graphical=graphical)


def generations() -> list[dict]:
    """The system generations, newest first."""
    result = subprocess.run([_rebuild(), "list-generations", "--json"], capture_output=True, text=True)
    if result.returncode != 0:
        raise YoError("Could not list generations:\n" + result.stderr.strip()[-1500:])
    try:
        entries = json.loads(result.stdout)
    except ValueError:
        raise YoError("Could not understand the list of generations")
    return sorted(entries, key=lambda entry: entry.get("generation", 0), reverse=True)


def collect_garbage(older_than: str | None, *, system: bool = True, on_line=None, graphical: bool = False) -> None:
    """Delete old generations and whatever nothing refers to any more."""
    arguments = ["--delete-older-than", older_than] if older_than else ["--delete-old"]
    collector = shutil.which("nix-collect-garbage") or "/run/current-system/sw/bin/nix-collect-garbage"
    code = run([collector, *arguments], on_line=on_line)
    if code == 0 and system:
        code = run(elevate([collector, *arguments], graphical=graphical), on_line=on_line)
    if code != 0:
        raise YoError(f"Garbage collection failed (exit status {code})")
