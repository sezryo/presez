"""Read and edit the plain-data Nix files that sets and profiles are written in.

Only the data subset of Nix is understood: attribute sets, lists, strings,
numbers, booleans and null, with comments. That is all a set or a profile.nix
may contain, and it is enough to edit them in place, keeping comments, order
and formatting intact.

Values are never interpreted here. This module only finds where things are
in the text; what a file means is always asked of Nix itself (see `evaluate`),
and every edit is checked against that before it is written.
"""

from __future__ import annotations

import json
import re
import subprocess
import tempfile
from dataclasses import dataclass, field
from pathlib import Path


class NotData(Exception):
    """The file uses Nix beyond plain data, so it has to be edited by hand."""


class EditError(Exception):
    """An edit could not be made, or did not produce the intended value."""


# --------------------------------------------------------------------------
# Syntax tree: just enough structure to locate things in the source text.


@dataclass
class Node:
    start: int
    end: int


@dataclass
class Scalar(Node):
    kind: str  # "string", "number", "word" (true, false, null)
    text: str = ""


@dataclass
class Binding(Node):
    path: list[str] = field(default_factory=list)
    value: Node | None = None


@dataclass
class AttrSet(Node):
    bindings: list[Binding] = field(default_factory=list)


@dataclass
class ListNode(Node):
    items: list[Node] = field(default_factory=list)


_IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_'-]*")
_NUMBER = re.compile(r"-?[0-9]+(\.[0-9]+)?")
_WORDS = {"true", "false", "null"}


class _Parser:
    def __init__(self, text: str):
        self.text = text
        self.pos = 0

    def fail(self, what: str):
        line = self.text.count("\n", 0, self.pos) + 1
        raise NotData(f"line {line}: {what}")

    def skip_trivia(self):
        text = self.text
        while self.pos < len(text):
            char = text[self.pos]
            if char in " \t\r\n":
                self.pos += 1
            elif char == "#":
                end = text.find("\n", self.pos)
                self.pos = len(text) if end < 0 else end
            elif text.startswith("/*", self.pos):
                end = text.find("*/", self.pos + 2)
                if end < 0:
                    self.fail("unterminated comment")
                self.pos = end + 2
            else:
                break

    def peek(self) -> str:
        self.skip_trivia()
        return self.text[self.pos] if self.pos < len(self.text) else ""

    def expect(self, token: str):
        if self.peek() != token:
            self.fail(f"expected {token!r}")
        self.pos += 1

    def string(self) -> Scalar:
        start = self.pos
        self.pos += 1
        text = self.text
        while self.pos < len(text):
            char = text[self.pos]
            if char == "\\":
                self.pos += 2
            elif char == '"':
                self.pos += 1
                return Scalar(start, self.pos, "string", text[start:self.pos])
            elif text.startswith("${", self.pos):
                self.fail("string interpolation is not plain data")
            else:
                self.pos += 1
        self.fail("unterminated string")

    def indented_string(self) -> Scalar:
        start = self.pos
        self.pos += 2
        text = self.text
        while self.pos < len(text):
            if text.startswith("'''", self.pos) or text.startswith("''$", self.pos):
                self.pos += 3
            elif text.startswith("''\\", self.pos):
                self.pos += 4
            elif text.startswith("''", self.pos):
                self.pos += 2
                return Scalar(start, self.pos, "string", text[start:self.pos])
            elif text.startswith("${", self.pos):
                self.fail("string interpolation is not plain data")
            else:
                self.pos += 1
        self.fail("unterminated string")

    def value(self) -> Node:
        char = self.peek()
        if char == "{":
            return self.attrset()
        if char == "[":
            return self.list()
        if char == '"':
            return self.string()
        if self.text.startswith("''", self.pos):
            return self.indented_string()
        number = _NUMBER.match(self.text, self.pos)
        if number:
            self.pos = number.end()
            return Scalar(number.start(), number.end(), "number", number.group())
        word = _IDENT.match(self.text, self.pos)
        if word and word.group() in _WORDS:
            self.pos = word.end()
            return Scalar(word.start(), word.end(), "word", word.group())
        self.fail("only plain data is understood here (no functions, variables or operators)")

    def attr_name(self) -> str:
        char = self.peek()
        if char == '"':
            return json.loads(self.string().text)
        word = _IDENT.match(self.text, self.pos)
        if not word or word.group() in {"inherit", "rec", "let", "with", "in", "if", "assert"}:
            self.fail("expected an attribute name")
        self.pos = word.end()
        return word.group()

    def attrset(self) -> AttrSet:
        start = self.pos
        self.expect("{")
        bindings = []
        while self.peek() != "}":
            if self.peek() == "":
                self.fail("unterminated attribute set")
            binding_start = self.pos
            path = [self.attr_name()]
            while self.peek() == ".":
                self.pos += 1
                self.skip_trivia()
                path.append(self.attr_name())
            self.expect("=")
            value = self.value()
            self.expect(";")
            bindings.append(Binding(binding_start, self.pos, path, value))
        self.pos += 1
        return AttrSet(start, self.pos, bindings)

    def list(self) -> ListNode:
        start = self.pos
        self.expect("[")
        items = []
        while self.peek() != "]":
            if self.peek() == "":
                self.fail("unterminated list")
            items.append(self.value())
        self.pos += 1
        return ListNode(start, self.pos, items)


def parse(text: str) -> AttrSet:
    """Parse a data file whose value is an attribute set."""
    parser = _Parser(text)
    if parser.peek() != "{":
        parser.fail("a data file must be an attribute set")
    root = parser.attrset()
    if parser.peek() != "":
        parser.fail("unexpected text after the attribute set")
    return root


# --------------------------------------------------------------------------
# Writing values.


def render(value, indent: str = "", inline: bool = False) -> str:
    """A Python value as Nix source."""
    if value is None:
        return "null"
    if value is True:
        return "true"
    if value is False:
        return "false"
    if isinstance(value, (int, float)):
        return repr(value)
    if isinstance(value, str):
        escaped = value.replace("\\", "\\\\").replace('"', '\\"').replace("${", "\\${")
        escaped = escaped.replace("\n", "\\n").replace("\t", "\\t").replace("\r", "\\r")
        return f'"{escaped}"'
    if isinstance(value, (list, tuple)):
        if not value:
            return "[ ]"
        simple = all(not isinstance(item, (list, tuple, dict)) for item in value)
        if inline or (simple and len(value) <= 6):
            return "[ " + " ".join(render(item, indent, True) for item in value) + " ]"
        inner = indent + "  "
        lines = [inner + render(item, inner) for item in value]
        return "[\n" + "\n".join(lines) + "\n" + indent + "]"
    if isinstance(value, dict):
        if not value:
            return "{ }"
        if inline:
            return "{ " + " ".join(f"{attr(key)} = {render(item, indent, True)};" for key, item in value.items()) + " }"
        inner = indent + "  "
        lines = [f"{inner}{attr(key)} = {render(item, inner)};" for key, item in value.items()]
        return "{\n" + "\n".join(lines) + "\n" + indent + "}"
    raise TypeError(f"cannot write {type(value).__name__} as Nix data")


def attr(name: str) -> str:
    """An attribute name, quoted only when it has to be."""
    if _IDENT.fullmatch(name) and name not in _WORDS:
        return name
    return render(name)


def attr_path(path: list[str]) -> str:
    return ".".join(attr(part) for part in path)


# --------------------------------------------------------------------------
# Asking Nix what a data file means.


def evaluate(text: str | None = None, *, path: Path | None = None):
    """The value of a data file, as Python data."""
    if text is None:
        target = str(path)
        handle = None
    else:
        handle = tempfile.NamedTemporaryFile("w", suffix=".nix", delete=False)
        handle.write(text)
        handle.close()
        target = handle.name
    try:
        result = subprocess.run(
            ["nix-instantiate", "--eval", "--strict", "--json", target],
            capture_output=True, text=True,
        )
    finally:
        if handle is not None:
            Path(handle.name).unlink(missing_ok=True)
    if result.returncode != 0:
        message = result.stderr.strip().splitlines()
        raise EditError("Nix could not evaluate the file: " + (message[-1] if message else "unknown error"))
    return json.loads(result.stdout)


# --------------------------------------------------------------------------
# Editing.


def _line_start(text: str, pos: int) -> int:
    return text.rfind("\n", 0, pos) + 1


def _line_end(text: str, pos: int) -> int:
    end = text.find("\n", pos)
    return len(text) if end < 0 else end


def _indent_of(text: str, pos: int) -> str:
    start = _line_start(text, pos)
    match = re.match(r"[ \t]*", text[start:])
    return match.group()


def _own_lines(text: str, node: Node) -> tuple[int, int] | None:
    """The span of whole lines `node` occupies alone, including a trailing comment."""
    start = _line_start(text, node.start)
    if text[start:node.start].strip():
        return None
    end = _line_end(text, node.end)
    rest = text[node.end:end].strip()
    if rest and not rest.startswith("#"):
        return None
    return start, min(end + 1, len(text))


def _is_multiline(text: str, node: Node) -> bool:
    return "\n" in text[node.start:node.end]


def _child_indent(text: str, container: AttrSet | ListNode) -> str:
    children = container.bindings if isinstance(container, AttrSet) else container.items
    for child in children:
        if _line_start(text, child.start) != _line_start(text, container.start):
            return _indent_of(text, child.start)
    return _indent_of(text, container.start) + "  "


def _insert_into(text: str, container: AttrSet | ListNode, entry: str) -> str:
    """Add `entry` as the last child of an attribute set or list."""
    close = container.end - 1
    if _is_multiline(text, container):
        indent = _child_indent(text, container)
        line = _line_start(text, close)
        entry = entry.replace("\n", "\n" + indent)
        if text[line:close].strip():
            # The closing bracket shares its line with content.
            return text[:close].rstrip() + "\n" + indent + entry + "\n" + _indent_of(text, container.start) + text[close:]
        return text[:line] + indent + entry + "\n" + text[line:]
    inner = text[container.start + 1:close]
    if inner.strip():
        return text[:close].rstrip() + " " + entry + " " + text[close:]
    # An empty container on one line is opened up.
    outer = _indent_of(text, container.start)
    entry = entry.replace("\n", "\n" + outer + "  ")
    return text[:container.start + 1] + "\n" + outer + "  " + entry + "\n" + outer + text[close:]


def _remove(text: str, node: Node) -> str:
    lines = _own_lines(text, node)
    if lines is not None:
        return text[:lines[0]] + text[lines[1]:]
    # Shares its line with siblings: drop it and one neighbouring space.
    start, end = node.start, node.end
    if text[end:end + 1] == " ":
        end += 1
    elif text[start - 1:start] == " ":
        start -= 1
    return text[:start] + text[end:]


def find(root: AttrSet, path: list[str]):
    """Locate `path`.

    Returns (binding, container, rest): the binding that defines the path
    exactly, or None with the deepest attribute set on the way and the part of
    the path that is still missing there.
    """
    container = root
    rest = list(path)
    while True:
        for binding in container.bindings:
            size = len(binding.path)
            if binding.path == rest:
                return binding, container, []
            if size < len(rest) and binding.path == rest[:size] and isinstance(binding.value, AttrSet):
                container, rest = binding.value, rest[size:]
                break
            if size > len(rest) and binding.path[:len(rest)] == rest:
                raise EditError(
                    f"{attr_path(path)} is spread over several definitions; please edit the file by hand")
        else:
            return None, container, rest


class Document:
    """A data file being edited."""

    def __init__(self, text: str, source: str = "<text>"):
        self.text = text
        self.source = source
        self.root = parse(text)

    @classmethod
    def load(cls, path: Path) -> "Document":
        try:
            return cls(path.read_text(), str(path))
        except NotData as error:
            raise NotData(f"{path}: {error}") from None

    def _apply(self, text: str):
        self.text = text
        self.root = parse(text)

    def has(self, path: list[str]) -> bool:
        binding, _, _ = find(self.root, path)
        return binding is not None

    def set(self, path: list[str], value):
        """Define `path` as `value`, replacing an existing definition."""
        binding, container, rest = find(self.root, path)
        if binding is not None:
            indent = _indent_of(self.text, binding.start)
            node = binding.value
            self._apply(self.text[:node.start] + render(value, indent) + self.text[node.end:])
            return
        indent = _child_indent(self.text, container) if _is_multiline(self.text, container) else ""
        entry = f"{attr_path(rest)} = {render(value, indent)};"
        text = _insert_into(self.text, container, entry)
        if container is self.root and container.bindings and _is_multiline(self.text, container):
            # Top-level definitions are set apart by a blank line.
            position = text.rfind(entry.split("\n")[0])
            line = _line_start(text, position)
            if text[:line].rstrip(" \t").endswith(";\n"):
                text = text[:line] + "\n" + text[line:]
        self._apply(text)

    def delete(self, path: list[str]):
        """Remove the definition of `path`, and attribute sets it leaves empty."""
        binding, _, _ = find(self.root, path)
        if binding is None:
            return
        text = _remove(self.text, binding)
        # Do not leave a blank line dangling before the closing brace.
        close = self.root.end - 1 - (len(self.text) - len(text))
        line = _line_start(text, close)
        if not text[line:close].strip() and text[:line].endswith("\n\n"):
            text = text[:line - 1] + text[line:]
        self._apply(text)
        # Prune attribute sets that are now empty, innermost first.
        for size in range(len(path) - 1, 0, -1):
            try:
                parent, _, _ = find(self.root, path[:size])
            except EditError:
                break  # other definitions still share this prefix
            if parent is None or not isinstance(parent.value, AttrSet) or parent.value.bindings:
                continue
            inside = self.text[parent.value.start + 1:parent.value.end - 1]
            if inside.strip():
                break  # comments are kept, and with them the attribute set
            self._apply(_remove(self.text, parent))

    def _list(self, path: list[str]) -> ListNode | None:
        binding, _, _ = find(self.root, path)
        if binding is None:
            return None
        if not isinstance(binding.value, ListNode):
            raise EditError(f"{attr_path(path)} is not a list")
        return binding.value

    def list_add(self, path: list[str], item):
        """Append `item` to the list at `path`, creating the list if needed."""
        node = self._list(path)
        if node is None:
            self.set(path, [item])
            # A list that may grow reads better one item per line.
            node = self._list(path)
            if not _is_multiline(self.text, node):
                indent = _indent_of(self.text, node.start)
                opened = "[\n" + indent + "  " + render(item, indent + "  ", True) + "\n" + indent + "]"
                self._apply(self.text[:node.start] + opened + self.text[node.end:])
            return
        self._apply(_insert_into(self.text, node, render(item, "", True)))

    def list_remove(self, path: list[str], matches) -> bool:
        """Remove the list items for which `matches(node, source)` is true."""
        removed = False
        while True:
            node = self._list(path)
            if node is None:
                return removed
            for item in node.items:
                if matches(item, self.text[item.start:item.end]):
                    self._apply(_remove(self.text, item))
                    removed = True
                    break
            else:
                return removed


def edit(path: Path, change, expected) -> str:
    """Edit the data file at `path` and verify the result before writing it.

    `change(document)` makes the edit; `expected(value)` maps the value the
    file had to the value it must have afterwards. The file is only written
    when Nix agrees that the new text means exactly that.
    """
    before = evaluate(path=path)
    document = Document.load(path)
    change(document)
    if document.text == path.read_text():
        return document.text
    wanted = expected(before)
    got = evaluate(document.text)
    if got != wanted:
        raise EditError(
            f"{path}: the edit did not produce the intended result, so nothing was written. "
            "Please edit the file by hand.")
    temporary = path.with_name(f".{path.name}.yo-tmp")
    temporary.write_text(document.text)
    temporary.replace(path)
    return document.text
