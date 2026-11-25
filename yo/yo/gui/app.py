"""The application window: overview, and building and applying changes."""

from __future__ import annotations

import sys

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
from gi.repository import Adw, Gdk, Gio, GLib, GObject, Gtk, Pango  # noqa: E402

from .. import __version__, failure, system, update  # noqa: E402
from ..repo import CACHE_PROBLEM, ProfileRef, foreign_cache_entries, nix_cache_dir  # noqa: E402
from .model import Model  # noqa: E402
from .pages import AddPackageDialog, PackageDialog, PackagesPage, SetsPage, UpdatesPage  # noqa: E402
from .util import (  # noqa: E402
    LogView, clamp, copy_text, empty, escape, first_line, icon_button, message_of, run_async, scrolled,
)

APP_ID = "org.presez.Yo"

CSS = """
/* Not 0.85em: at that size the default monospace font draws "=" as a single stroke. */
.yo-log { font-size: 0.9em; }
.yo-message { font-size: 0.9em; padding: 12px; }
.yo-hero-title { font-size: 1.7em; font-weight: 800; }
.yo-added { color: @success_color; }
.yo-removed { color: @error_color; }
"""


# ----------------------------------------------------------------- applying


class ApplyDialog(Adw.Dialog):
    """Build the configuration, show what would change, then switch to it.

    When a step fails, the dialog says which one, what was reported, where in
    the configuration to look, and what can be done about it.
    """

    EVALUATING = "Evaluating the configuration. This takes a couple of minutes and says nothing meanwhile."
    SUMMARIES = {
        "Updating": f"The versions could not be brought up to date, so nothing was built. {failure.UNCHANGED}",
        "Building": failure.UNCHANGED,
    }

    def __init__(self, window, update_first: bool = False):
        super().__init__(title="Apply Changes", content_width=720, content_height=660)
        self.window = window
        self.model = window.model
        self.built: str | None = None

        self.stack = Gtk.Stack(transition_type=Gtk.StackTransitionType.CROSSFADE, vexpand=True)

        # Working: what is happening, and the output of it.
        working = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, margin_top=18, margin_bottom=18,
                          margin_start=18, margin_end=18)
        head = Gtk.Box(spacing=12)
        head.append(Adw.Spinner(width_request=24, height_request=24))
        self.phase = Gtk.Label(xalign=0, hexpand=True)
        self.phase.add_css_class("title-4")
        head.append(self.phase)
        working.append(head)
        self.log = LogView()
        working.append(self.log)
        self.stack.add_named(working, "working")

        # Review: the changes, and the decision.
        self.review = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.stack.add_named(self.review, "review")

        # Result: how it ended, when it ended well.
        self.result = Adw.StatusPage(vexpand=True)
        self.stack.add_named(self.result, "result")

        # Failed: what went wrong. Filled in by `show_failure`.
        self.failed = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        self.stack.add_named(self.failed, "failed")

        view = Adw.ToolbarView()
        view.add_top_bar(Adw.HeaderBar())
        view.set_content(self.stack)
        # The whole output and a build's log open as further pages over this one.
        self.pages = Adw.NavigationView()
        self.pages.add(Adw.NavigationPage(title="Apply Changes", child=view))
        self.toasts = Adw.ToastOverlay(child=self.pages)
        self.set_child(self.toasts)
        self.start(update_first)

    def set_phase(self, text: str):
        self.phase.set_label(text)
        self.stack.set_visible_child_name("working")

    def toast(self, text: str):
        self.toasts.add_toast(Adw.Toast(title=escape(text), timeout=3))

    # ------------------------------------------------------------- building

    def start(self, update_first: bool = False):
        model = self.model
        self.log.clear()
        self.set_phase("Looking for newer versions…" if update_first else f"Building {model.ref.name}…")
        step = {"doing": "Updating" if update_first else "Building"}

        def building():
            self.set_phase(f"Building {model.ref.name}…")
            self.log.append(self.EVALUATING)

        def work():
            if update_first:
                changes = update.update(model.repo, update.select(model.repo, []), everything=True)
                for change in changes or ["Everything was already up to date."]:
                    self.log.append_from_thread(change)
                model.repo.reload()
            step["doing"] = "Building"
            GLib.idle_add(lambda: building() and False)
            built = system.build(model.repo, model.ref, on_line=self.log.append_from_thread)
            current = system.current_system()
            changes = system.closure_diff(current, built) if current else []
            return built, current, changes

        def failed(error):
            # A failed update is tried again as a whole; a failed build without updating once more.
            updating = step["doing"] == "Updating"
            self.fail(error, step["doing"], lambda: self.start(update_first=updating))

        run_async(work, self.reviewing, failed)

    def reviewing(self, outcome):
        built, current, changes = outcome
        self.built = built
        model = self.model
        if built == current:
            model.repo.record_applied(model.ref, built)
            self.result.set_icon_name("emblem-ok-symbolic")
            self.result.set_title("Nothing to Apply")
            self.result.set_description("The running system is already this configuration.")
            self.stack.set_visible_child_name("result")
            model.notify()
            return

        added = [change for change in changes if change.kind == "added"]
        removed = [change for change in changes if change.kind == "removed"]
        changed = [change for change in changes if change.kind == "changed"]

        content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=18)
        summary = Adw.PreferencesGroup(
            title="Ready to Switch",
            description=escape(f"{len(changed)} changed, {len(added)} added, {len(removed)} removed"
                               if changes else "Only settings change; no packages are added or removed."))
        content.append(summary)

        def section(title: str, items, text):
            if not items:
                return
            group = Adw.PreferencesGroup(title=title)
            for change in items[:150]:
                group.add(Adw.ActionRow(title=escape(change.name), subtitle=escape(text(change))))
            if len(items) > 150:
                group.add(Adw.ActionRow(title=f"… and {len(items) - 150} more"))
            content.append(group)

        section("Changed", changed, lambda c: f"{c.old} → {c.new}" if c.old != c.new else c.new)
        section("Added", added, lambda c: c.new)
        section("Removed", removed, lambda c: c.old)

        empty(self.review)
        self.review.append(scrolled(clamp(content, 560)))

        bar = Gtk.Box(spacing=12, halign=Gtk.Align.END, margin_top=10, margin_bottom=12, margin_end=18)
        cancel = Gtk.Button(label="Not Now")
        cancel.connect("clicked", lambda *_: self.close())
        bar.append(cancel)
        machine = self.window.machine_profile
        if machine is None or machine == model.ref:
            switch = Gtk.Button(label="Switch")
            switch.add_css_class("suggested-action")
            switch.connect("clicked", lambda *_: self.activate_system())
            bar.append(switch)
        else:
            note = Gtk.Label(label=f"{model.ref.name} is not this machine's profile, so it is only built.")
            note.add_css_class("dim-label")
            bar.prepend(note)
        self.review.append(bar)
        self.stack.set_visible_child_name("review")

    def activate_system(self):
        model = self.model
        built = self.built
        self.set_can_close(False)
        self.set_phase("Switching…")

        def work():
            system.activate(built, "switch", on_line=self.log.append_from_thread, graphical=True)
            model.repo.record_applied(model.ref, built)
            model.repo.remember_profile(model.ref)

        def done(_):
            self.set_can_close(True)
            self.result.set_icon_name("emblem-ok-symbolic")
            self.result.set_title("Switched")
            self.result.set_description(escape(f"This machine now runs {model.ref.name}."))
            self.stack.set_visible_child_name("result")
            model.refresh()

        run_async(work, done, lambda error: self.fail(error, "Switching", self.activate_system))

    # -------------------------------------------------------------- failing

    def fail(self, error: Exception, doing: str, retry):
        """Show what went wrong while `doing`; `retry()` does that step again."""
        self.set_can_close(True)
        found = failure.of(error, doing, self.SUMMARIES.get(doing, ""))
        try:
            self.show_failure(found, retry)
        except Exception:  # never leave the dialog on its spinner
            import traceback
            traceback.print_exc()
            self.result.set_icon_name("dialog-error-symbolic")
            self.result.set_title(escape(found.title))
            self.result.set_description(escape(found.summary + "\n\n" + found.message))
            self.stack.set_visible_child_name("result")

    def show_failure(self, found: failure.Failure, retry):
        model = self.model
        printed = self.log.text()
        if found.phase == "internal" or not printed:
            # Nothing of it went past in the log: a fault of Yo's own has its traceback there.
            printed = f"{printed}\n\n{found.log}".strip()
        empty(self.failed)
        content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=18)

        # What happened, in a sentence.
        head = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        icon = Gtk.Image(icon_name="dialog-error-symbolic", pixel_size=40, margin_bottom=4)
        icon.add_css_class("error")
        head.append(icon)
        title = Gtk.Label(label=found.title, wrap=True, justify=Gtk.Justification.CENTER)
        title.add_css_class("title-2")
        head.append(title)
        if found.summary:
            head.append(Gtk.Label(label=found.summary, wrap=True, justify=Gtk.Justification.CENTER))
        content.append(head)

        # What the failing tool said, word for word but without the noise around it.
        if found.message:
            group = Adw.PreferencesGroup(title="What Was Reported")
            message = Gtk.Label(label=found.message, selectable=True, wrap=True, xalign=0, hexpand=True,
                                wrap_mode=Pango.WrapMode.WORD_CHAR)
            message.add_css_class("monospace")
            message.add_css_class("yo-message")
            card = Gtk.Box()
            card.add_css_class("card")
            card.append(message)
            group.add(card)
            if found.advice:
                advice = Gtk.Label(label="\n".join(found.advice), wrap=True, xalign=0, margin_top=10,
                                   margin_start=4, margin_end=4)
                advice.add_css_class("dim-label")
                group.add(advice)
            content.append(group)

        # The files of this configuration that it is about.
        if found.places:
            group = Adw.PreferencesGroup(title="Where to Look")
            for place in found.places:
                why = place.why[:1].upper() + place.why[1:] if place.why else "Named in the report"
                row = Adw.ActionRow(title=escape(place.label), subtitle=escape(why), activatable=True,
                                    tooltip_text="Open this file")
                row.add_suffix(Gtk.Image(icon_name="document-open-symbolic"))
                row.connect("activated", lambda *_, file=place.file: self.window.open_file(file))
                group.add(row)
            content.append(group)

        # An update that no system was built from yet is the first suspect.
        waiting = update.pending(model.repo) if found.phase in ("evaluate", "build", "download") else None
        if waiting:
            group = Adw.PreferencesGroup(title=f"The Update of {update.when(waiting)}")
            row = Adw.ActionRow(
                title="Take the Update Back",
                subtitle="This is the first build since that update. If the configuration built before, the "
                         "update is the likely cause. The versions go back to what they were before it.",
                subtitle_lines=4, activatable=True)
            row.add_suffix(Gtk.Image(icon_name="edit-undo-symbolic"))
            row.connect("activated", lambda *_: self.undo_update())
            group.add(row)
            content.append(group)

        more = Adw.PreferencesGroup(title="More Detail")
        details = []
        if printed and printed.strip() != found.message.strip():
            details.append(("Everything That Was Printed", "", lambda *_: self.show_text("Output", printed)))
        if found.build_log and found.derivation:
            name = failure.derivation_name(found.derivation)
            details.append(("The Whole Log of This Build", name,
                            lambda *_: self.show_build_log(found.derivation, name)))
        for heading, subtitle, action in details:
            row = Adw.ActionRow(title=heading, subtitle=escape(subtitle), activatable=True)
            row.add_suffix(Gtk.Image(icon_name="go-next-symbolic"))
            row.connect("activated", action)
            more.add(row)
        if details:
            content.append(more)

        # Wide enough for 80 columns of what was reported, so that it keeps its own line breaks.
        self.failed.append(scrolled(clamp(content, 664)))

        bar = Gtk.Box(spacing=12, margin_top=10, margin_bottom=12, margin_start=18, margin_end=18)
        copy = Gtk.Button(label="Copy Report", tooltip_text="Copy what is on this page as text")
        copy.connect("clicked", lambda *_: self.copy(found.text()))
        bar.append(copy)
        bar.append(Gtk.Box(hexpand=True))
        again = Gtk.Button(label="Try Again")
        again.connect("clicked", lambda *_: retry())
        bar.append(again)
        self.failed.append(bar)

        self.stack.set_visible_child_name("failed")
        again.grab_focus()   # otherwise the report takes the focus and shows up selected

    def copy(self, text: str):
        copy_text(self, text)
        self.toast("Copied")

    def show_text(self, title: str, text: str):
        """Open a page over this one with `text` to read and copy."""
        log = LogView()
        log.set_text(text)
        for side in ("top", "bottom", "start", "end"):
            getattr(log, f"set_margin_{side}")(12)
        header = Adw.HeaderBar()
        copy = icon_button("edit-copy-symbolic", "Copy All of It")
        copy.connect("clicked", lambda *_: self.copy(text))
        header.pack_end(copy)
        view = Adw.ToolbarView()
        view.add_top_bar(header)
        view.set_content(log)
        self.pages.push(Adw.NavigationPage(title=title, child=view))

    def show_build_log(self, derivation: str, name: str):
        run_async(lambda: system.build_log(derivation),
                  lambda text: self.show_text(f"Log of {name}", text),
                  lambda error: self.toast(first_line(error)))

    def undo_update(self):
        model = self.model

        def done(_restored):
            self.close()
            self.window.toast("The update is taken back")
            model.refresh()

        run_async(lambda: update.undo(model.repo), done, lambda error: self.toast(first_line(error)))


# ----------------------------------------------------------------- overview


class OverviewPage(Gtk.Box):
    def __init__(self, window):
        super().__init__(orientation=Gtk.Orientation.VERTICAL)
        self.window = window
        self.model = window.model
        self.content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=24)
        self.append(scrolled(clamp(self.content, 680)))
        self.model.listeners.append(self.sync)
        self.sync()

    def sync(self):
        child = self.content.get_first_child()
        while child is not None:
            self.content.remove(child)
            child = self.content.get_first_child()
        model = self.model
        window = self.window

        hero = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4, margin_top=12)
        icon = Gtk.Image(icon_name=APP_ID, pixel_size=96, margin_bottom=8)
        hero.append(icon)
        title = Gtk.Label(label=model.ref.name)
        title.add_css_class("yo-hero-title")
        hero.append(title)
        sync = model.in_sync()
        machine = window.machine_profile
        broken_cache = bool(foreign_cache_entries())
        if broken_cache:
            state_text = "Nix's cache needs repair"
        elif machine is not None and machine != model.ref:
            state_text = f"Not this machine's profile (that is {machine.name})"
        elif model.state_error:
            state_text = "The configuration does not evaluate"
        elif sync is True:
            state_text = "The running system matches the configuration"
        elif sync is False:
            state_text = "Changes not applied yet"
        else:
            state_text = "Not applied with Yo yet"
        state = Gtk.Label(label=state_text)
        state.add_css_class("dim-label")
        hero.append(state)
        self.content.append(hero)

        actions = Gtk.Box(spacing=12, halign=Gtk.Align.CENTER)
        apply = Gtk.Button(label="Apply Changes" if sync is not True else "Rebuild")
        apply.add_css_class("pill")
        if sync is not True:
            apply.add_css_class("suggested-action")
        apply.connect("clicked", lambda *_: window.apply())
        actions.append(apply)
        upgrade = Gtk.Button(label="Update and Apply")
        upgrade.add_css_class("pill")
        upgrade.connect("clicked", lambda *_: window.apply(update_first=True))
        actions.append(upgrade)
        self.content.append(actions)

        if broken_cache:
            repair = Adw.PreferencesGroup(title="Problem")
            row = Adw.ActionRow(
                title="Nix's cache needs repair",
                subtitle=escape(CACHE_PROBLEM.format(directory=nix_cache_dir())), subtitle_lines=6)
            row.add_prefix(Gtk.Image(icon_name="dialog-warning-symbolic"))
            repair.add(row)
            button = Adw.ButtonRow(title="Give It Back to Me", start_icon_name="emblem-system-symbolic")
            button.connect("activated", lambda *_: window.repair_cache())
            repair.add(button)
            self.content.append(repair)
        elif model.state_error:
            broken = Adw.PreferencesGroup(title="Problem")
            row = Adw.ActionRow(title="The configuration does not evaluate",
                                subtitle=escape("\n".join(model.state_error.splitlines()[-6:])), subtitle_lines=8)
            row.add_prefix(Gtk.Image(icon_name="dialog-warning-symbolic"))
            broken.add(row)
            if model.can_undo():
                undo = Adw.ButtonRow(title="Undo the Last Change", start_icon_name="edit-undo-symbolic")
                undo.connect("activated", lambda *_: window.undo())
                broken.add(undo)
            self.content.append(broken)

        group = Adw.PreferencesGroup(title="This Configuration")
        profiles = model.repo.profiles()
        if len(profiles) > 1:
            names = [ref.name for ref in profiles]
            chooser = Adw.ComboRow(
                title="Profile",
                subtitle=escape(f"This machine is {machine.name}" if machine else "Which user and machine to look at"),
                model=Gtk.StringList.new(names))
            chooser.set_selected(profiles.index(model.ref))
            chooser.connect("notify::selected", lambda row, _p: window.change_profile(profiles[row.get_selected()]))
            group.add(chooser)
        else:
            group.add(Adw.ActionRow(title="Profile", subtitle=escape(model.ref.name)))
        on = sum(1 for name in model.repo.sets if model.set_on(name))
        sets = Adw.ActionRow(title="Sets", subtitle=f"{on} switched on, of {len(model.repo.sets)}", activatable=True)
        sets.add_suffix(Gtk.Image(icon_name="go-next-symbolic"))
        sets.connect("activated", lambda *_: window.stack.set_visible_child_name("sets"))
        group.add(sets)
        packages = Adw.ActionRow(title="Packages", subtitle=f"{len(model.packages())} selected", activatable=True)
        packages.add_suffix(Gtk.Image(icon_name="go-next-symbolic"))
        packages.connect("activated", lambda *_: window.stack.set_visible_child_name("packages"))
        group.add(packages)
        folder = Adw.ActionRow(title="Location", subtitle=escape(str(model.repo.root)), activatable=True)
        folder.add_suffix(Gtk.Image(icon_name="folder-open-symbolic"))
        folder.connect("activated", lambda *_: window.open_file(""))
        group.add(folder)
        self.content.append(group)

        history = Adw.PreferencesGroup(title="Generations", description="Earlier states of this system")
        generations = model.generations()
        current = next((entry for entry in generations if entry.get("current")), None)
        for entry in generations[:6]:
            row = Adw.ActionRow(
                title=f"Generation {entry['generation']}" + ("  ·  running" if entry.get("current") else ""),
                subtitle=escape(f"{entry.get('date', '')}  ·  NixOS {entry.get('nixosVersion', '?')}"
                                f"  ·  kernel {entry.get('kernelVersion', '?')}"))
            history.add(row)
        if current and any(entry["generation"] < current["generation"] for entry in generations):
            back = Adw.ButtonRow(title="Roll Back to the Previous Generation", start_icon_name="edit-undo-symbolic")
            back.connect("activated", lambda *_: window.roll_back())
            history.add(back)
        if generations:
            self.content.append(history)


# ------------------------------------------------------------------- window


class Window(Adw.ApplicationWindow):
    def __init__(self, app, model: Model, page: str | None):
        super().__init__(application=app, title="Yo", default_width=980, default_height=760)
        self.model = model
        self.set_icon_name(APP_ID)
        try:
            self.machine_profile = model.repo.resolve_profile(None)
        except Exception:
            self.machine_profile = None

        self.toasts = Adw.ToastOverlay()
        view = Adw.ToolbarView()
        header = Adw.HeaderBar()
        self.stack = Adw.ViewStack(vexpand=True)
        self.switcher = Adw.ViewSwitcher(stack=self.stack, policy=Adw.ViewSwitcherPolicy.WIDE)
        header.set_title_widget(self.switcher)

        menu = Gio.Menu()
        section = Gio.Menu()
        section.append("Change All My Machines", "win.shared")
        section.append("Undo Last Change", "win.undo")
        menu.append_section(None, section)
        section = Gio.Menu()
        section.append("Reload", "win.reload")
        section.append("Open Configuration Folder", "win.open-folder")
        menu.append_section(None, section)
        section = Gio.Menu()
        section.append("About Yo", "win.about")
        menu.append_section(None, section)
        header.pack_end(Gtk.MenuButton(icon_name="open-menu-symbolic", menu_model=menu, tooltip_text="Main Menu"))
        view.add_top_bar(header)

        self.cache_broken = False
        self.banner = Adw.Banner(button_label="Apply…")
        self.banner.connect("button-clicked", lambda *_: self.repair_cache() if self.cache_broken else self.apply())
        view.add_top_bar(self.banner)

        self.stack.add_titled_with_icon(OverviewPage(self), "overview", "Overview", "go-home-symbolic")
        self.stack.add_titled_with_icon(SetsPage(self), "sets", "Sets", "view-list-bullet-symbolic")
        self.stack.add_titled_with_icon(PackagesPage(self), "packages", "Packages", "package-x-generic-symbolic")
        self.stack.add_titled_with_icon(UpdatesPage(self), "updates", "Updates", "software-update-available-symbolic")
        view.set_content(self.stack)

        bar = Adw.ViewSwitcherBar(stack=self.stack)
        view.add_bottom_bar(bar)
        breakpoint = Adw.Breakpoint.new(Adw.BreakpointCondition.parse("max-width: 600sp"))
        breakpoint.add_setter(bar, "reveal", True)
        no_widget = GObject.Value()
        no_widget.init(Gtk.Widget.__gtype__)
        breakpoint.add_setter(header, "title-widget", no_widget)
        self.add_breakpoint(breakpoint)

        self.toasts.set_child(view)
        self.set_content(self.toasts)

        self.add_actions()
        model.listeners.append(self.sync)
        self.sync()
        if page in ("overview", "sets", "packages", "updates"):
            self.stack.set_visible_child_name(page)

    def add_actions(self):
        shared = Gio.SimpleAction.new_stateful("shared", None, GLib.Variant.new_boolean(self.model.shared))

        def toggle(action, _parameter):
            self.model.shared = not self.model.shared
            action.set_state(GLib.Variant.new_boolean(self.model.shared))
            self.toast("Changes now go to " + self.model.where())

        shared.connect("activate", toggle)
        self.add_action(shared)
        for name, handler in (
            ("undo", lambda *_: self.undo()),
            ("reload", lambda *_: self.model.refresh(lambda: self.toast("Reloaded"))),
            ("open-folder", lambda *_: self.open_file("")),
            ("about", lambda *_: self.about()),
        ):
            action = Gio.SimpleAction.new(name, None)
            action.connect("activate", handler)
            self.add_action(action)

    # ----------------------------------------------------------------- state

    def sync(self):
        sync = self.model.in_sync()
        machine = self.machine_profile
        self.cache_broken = bool(foreign_cache_entries())
        if self.cache_broken:
            self.banner.set_title("Parts of Nix's cache belong to root, so nothing can be evaluated or built")
            self.banner.set_button_label("Repair…")
            self.banner.set_revealed(True)
        elif self.model.state_error:
            self.banner.set_title("The configuration does not evaluate. See Overview")
            self.banner.set_button_label("")
            self.banner.set_revealed(True)
        elif machine is not None and machine != self.model.ref:
            self.banner.set_title(f"Looking at {self.model.ref.name}, which is not this machine")
            self.banner.set_button_label("Build…")
            self.banner.set_revealed(True)
        elif sync is True:
            self.banner.set_revealed(False)
        else:
            self.banner.set_title("Changes not applied yet" if sync is False
                                  else "Apply once with Yo to keep track of changes")
            self.banner.set_button_label("Apply…")
            self.banner.set_revealed(True)
        undo = self.lookup_action("undo")
        if undo is not None:
            undo.set_enabled(self.model.can_undo())

    def toast(self, text: str, undo: bool = False):
        toast = Adw.Toast(title=escape(text), timeout=4)
        if undo and self.model.can_undo():
            toast.set_button_label("Undo")
            toast.connect("button-clicked", lambda *_: self.undo())
        self.toasts.add_toast(toast)

    # --------------------------------------------------------------- actions

    def edit(self, change, done=None, failed=None):
        """Run a change to the configuration and report how it went."""

        def finished(message):
            if self.model.state_error:
                self.toast("That change breaks the configuration", undo=True)
            elif message:
                self.toast(str(message).splitlines()[0], undo=True)
            if done:
                done(message)

        def broke(error):
            self.toast(first_line(error))
            if failed:
                failed(error)

        self.model.apply_edit(change, finished, broke)

    def repair_cache(self):
        self.toast("Repairing Nix's cache…")
        run_async(lambda: system.repair_cache(graphical=True),
                  lambda _: (self.toast("Repaired"), self.model.refresh()),
                  lambda error: self.toast(first_line(error)))

    def undo(self):
        if self.model.can_undo():
            self.model.undo(lambda: self.toast("Undone"))

    def apply(self, update_first: bool = False):
        ApplyDialog(self, update_first).present(self)

    def add_package(self, into: str | None):
        AddPackageDialog(self, into).present(self)

    def show_package(self, name: str):
        PackageDialog(self, name).present(self)

    def change_profile(self, ref: ProfileRef):
        if ref == self.model.ref:
            return
        self.model.ref = ref
        self.model.state = None
        self.model.refresh()

    def roll_back(self):
        dialog = Adw.AlertDialog(
            heading="Roll Back?",
            body="The system switches to the previous generation. The configuration files stay as they are.")
        dialog.add_response("cancel", "Cancel")
        dialog.add_response("rollback", "Roll Back")
        dialog.set_response_appearance("rollback", Adw.ResponseAppearance.DESTRUCTIVE)
        dialog.set_default_response("cancel")
        dialog.set_close_response("cancel")

        def answered(_dialog, response):
            if response != "rollback":
                return
            self.toast("Rolling back…")
            run_async(lambda: system.rollback(graphical=True),
                      lambda _: (self.toast("Rolled back"), self.model.refresh()),
                      lambda error: self.toast(first_line(error)))

        dialog.connect("response", answered)
        dialog.present(self)

    def open_file(self, relative: str):
        target = self.model.repo.root / relative
        launcher = Gtk.FileLauncher.new(Gio.File.new_for_path(str(target)))
        launcher.launch(self, None, None)

    def about(self):
        dialog = Adw.AboutDialog(
            application_name="Yo", application_icon=APP_ID, version=__version__,
            comments="Manages the profiles, sets and packages of this NixOS configuration.")
        dialog.present(self)


class Application(Adw.Application):
    def __init__(self, root: str | None, profile: str | None, page: str | None):
        super().__init__(application_id=APP_ID, flags=Gio.ApplicationFlags.NON_UNIQUE)
        self.root = root
        self.profile = profile
        self.page = page
        self.window: Gtk.Window | None = None

    def do_startup(self):
        Adw.Application.do_startup(self)
        provider = Gtk.CssProvider()
        provider.load_from_string(CSS)
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
        # Text that can be selected should not come up selected just because it got the focus.
        Gtk.Settings.get_default().set_property("gtk-label-select-on-focus", False)
        self.set_accels_for_action("window.close", ["<Control>q", "<Control>w"])
        self.set_accels_for_action("win.reload", ["<Control>r", "F5"])
        self.set_accels_for_action("win.undo", ["<Control>z"])

    def do_activate(self):
        if self.window is not None:
            self.window.present()
            return
        # A placeholder while the configuration is read and evaluated.
        loading = Adw.ApplicationWindow(application=self, title="Yo", default_width=980, default_height=760)
        view = Adw.ToolbarView()
        view.add_top_bar(Adw.HeaderBar())
        status = Adw.StatusPage(title="Reading the Configuration…", vexpand=True)
        status.set_child(Adw.Spinner(width_request=32, height_request=32, halign=Gtk.Align.CENTER))
        view.set_content(status)
        loading.set_content(view)
        loading.present()
        self.window = loading

        def work():
            model = Model(self.root, self.profile)
            model.load()
            return model

        def done(model):
            window = Window(self, model, self.page)
            window.present()
            loading.close()
            self.window = window

        def failed(error):
            status.set_child(None)
            status.set_icon_name("dialog-error-symbolic")
            status.set_title("Could Not Read the Configuration")
            status.set_description(escape(message_of(error)))

        run_async(work, done, failed)


def run(root: str | None, profile: str | None, page: str | None = None) -> int:
    app = Application(root, profile, page)
    return app.run([sys.argv[0]])
