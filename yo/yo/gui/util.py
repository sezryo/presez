"""Shared pieces of the graphical interface."""

from __future__ import annotations

import threading
import traceback

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
from gi.repository import Adw, GLib, Gtk  # noqa: E402

from .. import failure  # noqa: E402
from ..nixdata import EditError, NotData  # noqa: E402
from ..repo import YoError  # noqa: E402

EXPECTED = (YoError, EditError, NotData)


def escape(text) -> str:
    return GLib.markup_escape_text(str(text))


def run_async(work, done=None, failed=None):
    """Run `work()` off the main loop and deliver its result back on it:
    `done(result)`, or `failed(error)` if it raised."""

    def deliver(callback, value):
        # `value` is this call's own name for what is delivered. The handler
        # below must not let the main loop reach for its `error` instead:
        # Python unsets the name of `except ... as error` when the handler
        # ends, which is before the main loop gets round to the callback.
        if callback is not None:
            GLib.idle_add(lambda: callback(value) and False)

    def target():
        try:
            result = work()
        except Exception as error:
            if not isinstance(error, EXPECTED):
                traceback.print_exc()
            deliver(failed, error)
        else:
            deliver(done, result)

    threading.Thread(target=target, daemon=True).start()


def message_of(error: Exception) -> str:
    text = str(error).strip() or error.__class__.__name__
    return text


def first_line(error: Exception) -> str:
    """A failure in one line, for a toast: what failed, and the heart of why."""
    found = failure.of(error)
    lines = [line.strip() for line in found.message.splitlines() if line.strip()]
    if not lines:
        return found.title
    if found.title == failure.PLAIN:
        return lines[0]
    return f"{found.title}: {lines[-1]}"


def copy_text(widget: Gtk.Widget, text: str):
    widget.get_clipboard().set(text)


def empty(box: Gtk.Box):
    child = box.get_first_child()
    while child is not None:
        box.remove(child)
        child = box.get_first_child()


def icon_button(icon: str, tooltip: str, *classes: str) -> Gtk.Button:
    button = Gtk.Button(icon_name=icon, tooltip_text=tooltip, valign=Gtk.Align.CENTER)
    for name in classes or ("flat",):
        button.add_css_class(name)
    return button


def clamp(child: Gtk.Widget, size: int = 760) -> Adw.Clamp:
    return Adw.Clamp(child=child, maximum_size=size, tightening_threshold=size - 160,
                     margin_top=18, margin_bottom=24, margin_start=12, margin_end=12)


def scrolled(child: Gtk.Widget) -> Gtk.ScrolledWindow:
    return Gtk.ScrolledWindow(child=child, hscrollbar_policy=Gtk.PolicyType.NEVER, vexpand=True)


def humanise(description: str) -> str:
    """An option description as a short phrase."""
    text = " ".join(description.split())
    for prefix in ("Whether to enable ", "Whether to ", "Enable this if ", "Enable this to ", "Enable "):
        if text.startswith(prefix):
            text = text[len(prefix):]
            break
    text = text.rstrip(".")
    return text[:1].upper() + text[1:] if text else ""


class LogView(Gtk.ScrolledWindow):
    """A scrolling, monospaced view of command output."""

    def __init__(self, height: int = 220):
        super().__init__(min_content_height=height, vexpand=True)
        self.add_css_class("card")
        self.buffer = Gtk.TextBuffer()
        self.view = Gtk.TextView(buffer=self.buffer, editable=False, cursor_visible=False, monospace=True,
                                 wrap_mode=Gtk.WrapMode.WORD_CHAR, top_margin=8, bottom_margin=8,
                                 left_margin=10, right_margin=10)
        self.view.add_css_class("yo-log")
        self.set_child(self.view)

    def append(self, line: str):
        end = self.buffer.get_end_iter()
        self.buffer.insert(end, line + "\n")
        mark = self.buffer.create_mark(None, self.buffer.get_end_iter(), False)
        self.view.scroll_mark_onscreen(mark)
        self.buffer.delete_mark(mark)

    def text(self) -> str:
        return self.buffer.get_text(self.buffer.get_start_iter(), self.buffer.get_end_iter(), False).strip()

    def set_text(self, text: str):
        """Show `text`, scrolled to its end: that is where a failure says what it is."""
        self.buffer.set_text(text)

        def to_end():
            mark = self.buffer.create_mark(None, self.buffer.get_end_iter(), False)
            self.view.scroll_to_mark(mark, 0.0, True, 0.0, 1.0)
            self.buffer.delete_mark(mark)

        GLib.idle_add(lambda: to_end() and False)

    def clear(self):
        self.buffer.set_text("")

    def append_from_thread(self, line: str):
        GLib.idle_add(lambda: self.append(line) and False)
