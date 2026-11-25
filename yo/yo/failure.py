"""Saying what went wrong, readably.

Nix reports a failure either as a long trace through its own library with the
actual message at the very end, or as a list of things it could not build with
the cause in a builder's log. `explain` reads that output and returns a
`Failure`: a title, one sentence about what it means, the message itself, and
the places in this configuration that it points to.

The terminal and the window both show failures from here, so that they say the
same thing.
"""

from __future__ import annotations

import os
import re
import traceback
from dataclasses import dataclass, field
from pathlib import Path

from .repo import YoError

UNCHANGED = "This system is unchanged."
TAIL = 12                         # how many of a builder's last lines a failure quotes
PLAIN = "That Did Not Work"       # the title of a failure that says everything in its message


@dataclass
class Place:
    """A file of this configuration that has to do with a failure."""

    file: str                 # relative to the configuration's root
    line: int | None = None
    why: str = ""             # how it relates, when the message does not name it itself

    @property
    def label(self) -> str:
        return self.file if self.line is None else f"{self.file}, line {self.line}"


@dataclass
class Failure:
    phase: str                # update, evaluate, build, download, activate, denied or internal
    title: str
    summary: str
    message: str = ""         # what the failing tool said, without the noise around it
    places: list[Place] = field(default_factory=list)
    advice: list[str] = field(default_factory=list)
    log: str = ""             # everything that was printed
    derivation: str = ""      # the store derivation that failed to build, if one did
    build_log: str = ""       # the command that prints that build's whole log, if there is one

    def text(self) -> str:
        """The failure as plain text, for a terminal or the clipboard."""
        parts = [self.title, self.summary]
        if self.message:
            parts += ["", *("  " + line if line else "" for line in self.message.splitlines())]
        if self.places:
            parts.append("")
            parts += [f"{place.label}" + (f"  ({place.why})" if place.why else "") for place in self.places]
        notes = self.advice + ([f"The whole log of this build: {self.build_log}"] if self.build_log else [])
        if notes:
            parts += ["", *notes]
        return "\n".join(parts)


class Failed(YoError):
    """Something failed in a way that is worth explaining: carries a `Failure`."""

    def __init__(self, failure: Failure):
        super().__init__(failure.title)
        self.failure = failure

    def __str__(self) -> str:
        return self.failure.text()


# ------------------------------------------------------------ reading output

ANSI = re.compile(r"\x1b\[[0-9;?]*[A-Za-z]")
# Lines that say what Nix is doing rather than what went wrong.
PROGRESS = ("unpacking ", "copying path ", "copying ", "warning: Git tree ", "remote: ", "From https://", " * [new ")

CANNOT_BUILD = re.compile(r"error: Cannot build '(?P<drv>/nix/store/[^']+)'")
BUILDER_FAILED = re.compile(r"error: builder for '(?P<drv>/nix/store/[^']+)' failed with exit code (?P<code>\d+)")
DEPENDENCY_FAILED = re.compile(r"\d+ dependenc(?:y|ies) (?:of derivation '[^']+' )?failed")
HASH_MISMATCH = re.compile(r"error: hash mismatch in fixed-output derivation '(?P<drv>/nix/store/[^']+)'")
REASON = re.compile(r"^\s*Reason: (?P<reason>.+?)\.?$")
EXIT_CODE = re.compile(r"exit code (\d+)")
NIX_LOG = re.compile(r"(nix log /nix/store/[^\s'\"]+\.drv)")
NO_NETWORK = re.compile(
    r"Could(?: not|n't) resolve host|unable to download|cannot download .* from any mirror"
    r"|Network is unreachable|Connection timed out|Failed to connect to|Connection refused"
    r"|Temporary failure in name resolution|SSL connection timeout|Could not connect to server",
    re.IGNORECASE)
DISK_FULL = re.compile(r"No space left on device", re.IGNORECASE)

STORE_FILE = re.compile(
    r"(?P<store>/nix/store/[0-9a-z]{32}-[^/\s'\"`:]+)/(?P<file>[^\s'\"`:,;)]+)(?::(?P<line>\d+))?")
# A dotted name that a message quotes, like `services.foo.enable'.
QUOTED_NAME = re.compile(r"[`'‘\"]([A-Za-z_][\w'-]*(?:\.[\w'-]+)+)['’`\"]")
# What this configuration's own checks say about a selection (lib/packages.nix).
UNKNOWN_SELECTION = re.compile(
    r"Selected package(?P<variants> variants that do not exist under src/"
    r"|s that are neither in src/ nor in nixpkgs): (?P<names>.+)")


def clean(output: str) -> list[str]:
    return [ANSI.sub("", line).rstrip() for line in output.splitlines()]


def blocks(lines: list[str]) -> list[list[str]]:
    """Nix's errors, each as its own list of lines.

    An error starts with `error:` at the beginning of a line and goes on for
    as long as the lines after it are indented.
    """
    found: list[list[str]] = []
    current: list[str] | None = None
    for line in lines:
        if line.startswith("error:"):
            current = [line]
            found.append(current)
        elif current is not None and (not line.strip() or line[0] in " \t"):
            current.append(line)
        else:
            current = None
    for block in found:
        while block and not block[-1].strip():
            block.pop()
    return found


def dedent(lines: list[str]) -> list[str]:
    margins = [len(line) - len(line.lstrip()) for line in lines if line.strip()]
    margin = min(margins, default=0)
    return [line[margin:] if line.strip() else "" for line in lines]


def trim(lines: list[str]) -> list[str]:
    """Without the empty lines at either end."""
    start, end = 0, len(lines)
    while start < end and not lines[start].strip():
        start += 1
    while end > start and not lines[end - 1].strip():
        end -= 1
    return lines[start:end]


def split(block: list[str]) -> tuple[list[str], list[str]]:
    """An error as (the trace that leads up to it, its message).

    Nix prints the trace first, outermost step first, and then the message
    under one more `error:`.
    """
    starts = [index for index, line in enumerate(block) if line.lstrip().startswith("error:")]
    if not starts:
        return [], trim(dedent(block))
    start = starts[-1]
    first = block[start].lstrip()[len("error:"):].strip()
    return block[:start], trim(([first] if first else []) + dedent(block[start + 1:]))


def is_consequence(block: list[str]) -> bool:
    """Does this error only say that something else failed first?"""
    reason = next((found["reason"] for found in map(REASON.match, block) if found), "")
    return bool(DEPENDENCY_FAILED.search(reason) or DEPENDENCY_FAILED.search(block[0]))


def derivation_name(path: str) -> str:
    """`/nix/store/<hash>-foo-1.2.drv` as `foo-1.2`."""
    name = os.path.basename(path)
    name = re.sub(r"^[0-9a-z]{32}-", "", name)
    return name[:-4] if name.endswith(".drv") else name


def package_name(name: str) -> str:
    """`foo-bar-1.2.3` as `foo-bar`: the part before the version."""
    match = re.match(r"(.+?)-(?=\d)", name)
    return match.group(1) if match else name


# ----------------------------------------------------- places in the configuration


class _Trees:
    """Tells which store directories are copies of the configuration."""

    def __init__(self, root: Path | None):
        self.root = root
        self.known: dict[str, bool] = {}

    def ours(self, store: str) -> bool:
        if self.root is None:
            return False
        if store not in self.known:
            try:
                same = (Path(store) / "flake.nix").read_bytes() == (self.root / "flake.nix").read_bytes()
            except OSError:
                same = False
            self.known[store] = same
        return self.known[store]

    def places(self, text: str, why: str = "") -> list[Place]:
        found: list[Place] = []
        for match in STORE_FILE.finditer(text):
            if not self.ours(match["store"]):
                continue
            relative = match["file"].rstrip(".")
            if not (self.root / relative).is_file():
                continue
            place = Place(relative, int(match["line"]) if match["line"] else None, why)
            if all((known.file, known.line) != (place.file, place.line) for known in found):
                found.append(place)
        return found

    def localise(self, text: str) -> str:
        """`text` with paths into a copy of the configuration made relative to it."""
        stores = {match["store"] for match in STORE_FILE.finditer(text)}
        for store in sorted(stores, key=len, reverse=True):
            if self.ours(store):
                text = text.replace(store + "/", "")
        return text


def _nix_files(root: Path):
    for directory, names, files in os.walk(root):
        names[:] = sorted(name for name in names if not name.startswith(".") and name != "__pycache__")
        for name in sorted(files):
            if name.endswith(".nix"):
                yield Path(directory) / name


def mentions(message: str, root: Path | None, limit: int = 3) -> list[Place]:
    """Places in the configuration that use a name the message quotes.

    A failed check says what is wrong but not where it comes from; the names
    it quotes usually stand in the file that has to change.
    """
    if root is None:
        return []
    names = sorted(set(QUOTED_NAME.findall(message)), key=lambda name: (-len(name), name))
    if not names:
        return []
    texts: dict[Path, list[str]] = {}
    for path in _nix_files(root):
        try:
            texts[path] = path.read_text(errors="replace").splitlines()
        except OSError:
            continue
    found: list[Place] = []
    for name in names:
        pattern = re.compile(re.escape(name) + r"(?![\w'-])")
        hits = []
        for path, lines in texts.items():
            for number, line in enumerate(lines, 1):
                if pattern.search(line) and not line.lstrip().startswith("#"):
                    hits.append(Place(str(path.relative_to(root)), number, f"uses {name}"))
                    break
        if len(hits) > 6:
            continue                    # used all over the place: says nothing about where
        for place in hits:
            if all(known.file != place.file for known in found):
                found.append(place)
        if len(found) >= limit:
            break
    return found[:limit]


def selections(message: str, root: Path | None, limit: int = 3) -> list[Place]:
    """Where the packages are selected that the configuration's own check turns down."""
    if root is None:
        return []
    found: list[Place] = []
    for match in UNKNOWN_SELECTION.finditer(message):
        for name in (part.strip() for part in match["names"].split(",")):
            # A variant is told as package.variant; a package's own name may have dots too.
            package = name.rpartition(".")[0] if "variants" in match["variants"] else name
            if not package:
                continue
            selected = re.compile(r'"{0}"|(?<![\w.-]){0}\s*='.format(re.escape(package)))
            for directory in ("profiles", "modules"):
                for path in _nix_files(root / directory):
                    try:
                        lines = path.read_text(errors="replace").splitlines()
                    except OSError:
                        continue
                    for number, line in enumerate(lines, 1):
                        if selected.search(line) and not line.lstrip().startswith("#"):
                            found.append(Place(str(path.relative_to(root)), number, f"selects {package}"))
                            break
    return found[:limit]


# ------------------------------------------------------------------ explaining


def _advice_for(text: str) -> list[str]:
    advice = []
    if DISK_FULL.search(text):
        advice.append("The disk is full. Old generations can be deleted with: yo gc")
    return advice


def _build_failure(block: list[str], root: Path | None) -> Failure:
    head = block[0]
    match = CANNOT_BUILD.search(head) or BUILDER_FAILED.search(head)
    drv = match["drv"]
    name = derivation_name(drv)
    reason = next((found["reason"] for found in map(REASON.match, block) if found), "")
    code = EXIT_CODE.search(reason) or EXIT_CODE.search(head)
    output = [line.strip()[1:].removeprefix(" ") for line in block if line.strip().startswith(">")]
    text = "\n".join(block)
    command = NIX_LOG.search(text)

    if output:
        # The cause is nearly always at the very end; the rest is one step away, in the whole log.
        output = trim(output)
        tail = output[-TAIL:]
        said = "The builder stopped" + (f" with exit code {code.group(1)}" if code else "") + ". Its last lines:"
        message = "\n".join([said, "", *(["…"] if len(output) > len(tail) else []), *tail])
    else:
        message = "\n".join(trim(dedent(block[1:]))) or head

    failure = Failure(
        phase="build",
        title=f"{name} Did Not Build",
        summary=f"One of the packages of the new system could not be built. {UNCHANGED}",
        message=message, derivation=drv, advice=_advice_for(text))
    if NO_NETWORK.search(text):
        failure.phase = "download"
        failure.title = f"{name} Could Not Be Downloaded"
        failure.summary = f"Something the new system needs could not be fetched from the network. {UNCHANGED}"
        failure.advice.append("Check the network connection and try again.")
    if command:
        failure.build_log = command.group(1)
    failure.places = _package_places(name, root)
    return failure


def _hash_failure(block: list[str], root: Path | None) -> Failure:
    drv = HASH_MISMATCH.search(block[0])["drv"]
    name = derivation_name(drv)
    failure = Failure(
        phase="build",
        title=f"{name} Is Not What Was Pinned",
        summary=("A download does not have the hash that the configuration expects: either it changed "
                 f"at its source, or the pinned hash is out of date. {UNCHANGED}"),
        message="\n".join(trim(dedent(block[1:]))), derivation=drv)
    failure.places = _package_places(name, root)
    package = package_name(name)
    if root is not None and (root / "src" / package / "meta.nix").is_file():
        failure.advice.append(f"If {package} is pinned here, refresh the pin with: yo update {package}")
    return failure


def _package_places(name: str, root: Path | None) -> list[Place]:
    """This configuration's own files for the package a derivation belongs to."""
    if root is None:
        return []
    for candidate in dict.fromkeys((package_name(name), name)):
        directory = root / "src" / candidate
        if directory.is_dir():
            files = sorted(path.name for path in directory.glob("*.nix") if path.name != "meta.nix")
            target = f"src/{candidate}/{files[0]}" if len(files) == 1 else f"src/{candidate}"
            return [Place(target, None, f"this configuration's own setup of {candidate}")]
    return []


def _evaluation_failure(block: list[str], trees: _Trees, root: Path | None, profile: str) -> Failure:
    whole = "\n".join(block)
    trace, message_lines = split(block)
    message = "\n".join(message_lines)
    what = f"what to build for {profile}" if profile else "what to build"

    places = trees.places(message)
    if not places:
        # The message is about someone else's file; the trace may pass through ours.
        places = [Place(place.file, place.line, "Nix was reading this when it stopped")
                  for place in trees.places("\n".join(trace))][-2:]
    if not places:
        places = selections(message, root) or mentions(message, root)

    failure = Failure(
        phase="evaluate",
        title="The Configuration Has an Error",
        summary=f"Nix could not work out {what}, so nothing was built. {UNCHANGED}",
        message=trees.localise(message), places=places, advice=_advice_for(whole))
    if message_lines and message_lines[0].startswith("Failed assertions"):
        failure.title = "The Configuration Fails a Check"
        failure.summary = f"A module refuses this configuration and says why. Nothing was built. {UNCHANGED}"
    elif NO_NETWORK.search(message):
        failure.phase = "download"
        failure.title = "A Download Failed"
        failure.summary = f"Something the configuration needs could not be fetched from the network. {UNCHANGED}"
        failure.advice.append("Check the network connection and try again.")
    return failure


def explain(output: str, root: Path | None = None, profile: str = "") -> Failure:
    """What the output of a failed `nix build` means."""
    lines = clean(output)
    log = "\n".join(lines).strip()
    trees = _Trees(root)
    found = blocks(lines)

    failure = None
    for block in found:
        head = block[0]
        if HASH_MISMATCH.search(head):
            failure = _hash_failure(block, root)
        elif (BUILDER_FAILED.search(head) or CANNOT_BUILD.search(head)) and not is_consequence(block):
            failure = _build_failure(block, root)
        if failure is not None:
            break
    if failure is None:
        # No builder failed: the last error that is not a mere consequence.
        causes = [block for block in found if not is_consequence(block)]
        if causes:
            failure = _evaluation_failure(causes[-1], trees, root, profile)
        elif found:
            failure = Failure(
                phase="build", title="The Build Failed",
                summary=f"Nix could not build everything the new system needs. {UNCHANGED}",
                message="\n".join(line for block in found for line in trim(dedent(block))))
    if failure is None:
        kept = [line for line in lines if line.strip() and not line.startswith(PROGRESS)]
        failure = Failure(
            phase="build", title="The Build Failed",
            summary=f"Nix stopped without saying clearly why. {UNCHANGED}",
            message="\n".join(kept[-25:]))
    failure.log = log
    return failure


def of(error: BaseException, doing: str = "", summary: str = "") -> Failure:
    """A failure for any exception.

    `doing` names the step, as in "Updating", and `summary` says what its
    failing means; both are for errors that do not explain themselves.
    """
    if isinstance(error, Failed):
        return error.failure
    from .nixdata import EditError, NotData
    text = str(error).strip()
    if isinstance(error, (YoError, EditError, NotData)):
        first, _, rest = text.partition("\n")
        if rest.strip() and first.rstrip().endswith(":"):
            # "Updating flake inputs failed:" followed by what the tool printed.
            title, message = first.rstrip(":").rstrip(), rest.strip()
        else:
            title, message = (f"{doing} Failed" if doing else PLAIN), text
        return Failure(phase=doing.lower() or "other", title=_headline(title), summary=summary,
                       message=message, log=text)
    trace = "".join(traceback.format_exception(type(error), error, error.__traceback__))
    return Failure(
        phase="internal", title="Yo Ran Into a Problem of Its Own",
        summary="This is a fault in Yo, not in the configuration.",
        message=f"{type(error).__name__}: {text}" if text else type(error).__name__, log=trace.strip())


def _headline(text: str) -> str:
    """A sentence as a heading: its words capitalised, the short ones excepted."""
    small = {"a", "an", "the", "of", "for", "to", "in", "on", "and", "or", "with", "from", "at", "by"}
    words = text.split()
    return " ".join(
        word if index and word.lower() in small else word[:1].upper() + word[1:]
        for index, word in enumerate(words))
