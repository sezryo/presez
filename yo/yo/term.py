"""Small helpers for output in a terminal."""

from __future__ import annotations

import os
import shutil
import sys

_CODES = {
    "bold": "1", "dim": "2", "red": "31", "green": "32", "yellow": "33",
    "blue": "34", "magenta": "35", "cyan": "36",
}

enabled = sys.stdout.isatty() and "NO_COLOR" not in os.environ


def style(text: str, *names: str) -> str:
    if not enabled or not names:
        return text
    return f"\x1b[{';'.join(_CODES[name] for name in names)}m{text}\x1b[0m"


def bold(text: str) -> str:
    return style(text, "bold")


def dim(text: str) -> str:
    return style(text, "dim")


def good(text: str) -> str:
    return style(text, "green")


def warn(text: str) -> str:
    return style(text, "yellow")


def bad(text: str) -> str:
    return style(text, "red")


def width() -> int:
    return shutil.get_terminal_size((100, 24)).columns


def shorten(text: str, limit: int) -> str:
    text = " ".join(text.split())
    return text if len(text) <= limit else text[: max(limit - 1, 1)] + "…"


def table(rows: list[tuple], indent: str = "  ") -> list[str]:
    """Rows as aligned columns; the last column takes what is left."""
    if not rows:
        return []
    count = max(len(row) for row in rows)
    plain = [[str(cell) for cell in row] + [""] * (count - len(row)) for row in rows]
    widths = [max(_visible(row[index]) for row in plain) for index in range(count - 1)]
    lines = []
    for row in plain:
        cells = [cell + " " * (widths[index] - _visible(cell)) for index, cell in enumerate(row[:-1])]
        lines.append((indent + "  ".join(cells + [row[-1]])).rstrip())
    return lines


def _visible(text: str) -> int:
    import re
    return len(re.sub(r"\x1b\[[0-9;]*m", "", text))


def info(message: str):
    print(message)


def note(message: str):
    print(dim(message))


def error(message: str):
    print(f"{bad('error:')} {message}", file=sys.stderr)


def confirm(question: str, default: bool = True) -> bool:
    if not sys.stdin.isatty():
        return default
    suffix = " [Y/n] " if default else " [y/N] "
    try:
        answer = input(question + suffix).strip().lower()
    except (EOFError, KeyboardInterrupt):
        print()
        return False
    if not answer:
        return default
    return answer in {"y", "yes"}


def ask(question: str, default: str = "") -> str:
    if not sys.stdin.isatty():
        return default
    suffix = f" [{default}] " if default else " "
    try:
        answer = input(question + suffix).strip()
    except (EOFError, KeyboardInterrupt):
        print()
        return default
    return answer or default
