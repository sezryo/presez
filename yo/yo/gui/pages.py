"""The Sets, Packages and Updates pages."""

from __future__ import annotations

import json
import subprocess
from concurrent.futures import ThreadPoolExecutor

import gi

gi.require_version("Gtk", "4.0")
gi.require_version("Adw", "1")
from gi.repository import Adw, Gio, GLib, Gtk, Pango  # noqa: E402

from .. import edit, update  # noqa: E402
from .util import clamp, escape, first_line, humanise, icon_button, run_async, scrolled  # noqa: E402

UNSET = "Not set"


def value_text(value) -> str:
    if isinstance(value, bool):
        return "On" if value else "Off"
    if isinstance(value, list):
        return ", ".join(map(str, value)) if value else "None"
    if value is None:
        return UNSET
    return str(value)


class SearchablePage(Gtk.Box):
    """A page with a search field above scrolling content."""

    def __init__(self, window, placeholder: str):
        super().__init__(orientation=Gtk.Orientation.VERTICAL)
        self.window = window
        self.model = window.model
        self.search = Gtk.SearchEntry(placeholder_text=placeholder, hexpand=True)
        self.search.connect("search-changed", lambda *_: self.filter())
        self.append(Adw.Clamp(child=self.search, maximum_size=520, margin_top=12, margin_bottom=2,
                              margin_start=12, margin_end=12))
        self.content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=24)
        self.append(scrolled(clamp(self.content)))

    def needle(self) -> str:
        return self.search.get_text().strip().lower()

    def filter(self):
        raise NotImplementedError


# --------------------------------------------------------------------- sets


class SetRow:
    """One set: a switch, and what it contains when opened."""

    def __init__(self, page: "SetsPage", name: str):
        self.page = page
        self.model = page.model
        self.name = name
        self.short = name.split(".", 1)[1] if "." in name else name
        self.updating = False
        self.children: list[Gtk.Widget] = []
        self.switch: Gtk.Switch | None = None
        self.row = Adw.ExpanderRow(title=escape(self.short))
        self.status = Gtk.Label(valign=Gtk.Align.CENTER)
        self.status.add_css_class("dim-label")
        self.status.add_css_class("caption")
        if self.model.option(name + ".enable") is not None or self.model.repo.sets[name]["kind"] == "data":
            self.switch = Gtk.Switch(valign=Gtk.Align.CENTER)
            self.switch.connect("notify::active", self.on_switch)
            self.row.add_suffix(self.switch)
        self.row.add_suffix(self.status)
        self.sync()

    @property
    def entry(self) -> dict:
        return self.model.repo.sets[self.name]

    def description(self) -> str:
        if self.entry.get("description"):
            return humanise(self.entry["description"])
        option = self.model.option(self.name + ".enable") or self.model.option(self.name)
        return humanise((option or {}).get("description", ""))

    def searchable(self) -> str:
        parts = [self.name, self.description(), " ".join(self.entry.get("packages", {}))]
        parts += [option["name"] for option in self.model.options(self.name)]
        return " ".join(parts).lower()

    def on_switch(self, switch, _param):
        if self.updating:
            return
        wanted = switch.get_active()
        self.page.window.edit(lambda: self.model.switch_set(self.name, wanted))

    def sync(self):
        self.updating = True
        on = self.model.set_on(self.name)
        self.row.set_subtitle(escape(self.description()))
        why = self.model.selection["sets"].get(self.name, "")
        self.status.set_label(why.replace("set ", "via ") if on and why.startswith("set ") else "")
        if self.switch is not None:
            self.switch.set_active(bool(on))
        for child in self.children:
            self.row.remove(child)
        self.children = []
        for child in self.build_children():
            self.row.add_row(child)
            self.children.append(child)
        self.updating = False

    def build_children(self) -> list[Gtk.Widget]:
        rows: list[Gtk.Widget] = []
        for option in self.model.options(self.name):
            if option["name"] == self.name + ".enable":
                continue
            rows.append(self.page.option_row(option, self.name))
        entry = self.entry
        if entry["kind"] == "data":
            if entry.get("sets"):
                rows.append(Adw.ActionRow(title="Switches on", subtitle=escape(", ".join(entry["sets"])),
                                          subtitle_lines=3))
            for package, variants in sorted(entry.get("packages", {}).items()):
                rows.append(self.package_row(package, variants))
            add = Adw.ButtonRow(title="Add Package…", start_icon_name="list-add-symbolic")
            add.connect("activated", lambda *_: self.page.window.add_package(self.name))
            rows.append(add)
        else:
            source = Adw.ActionRow(title="Written as a module",
                                   subtitle=escape(entry["file"]), activatable=True)
            source.add_suffix(Gtk.Image(icon_name="document-open-symbolic"))
            source.connect("activated", lambda *_: self.page.window.open_file(entry["file"]))
            rows.append(source)
        return rows

    def package_row(self, package: str, variants: list[str]) -> Gtk.Widget:
        known = package in self.model.repo.packages
        subtitle = "Configured under src/" if known else "From nixpkgs"
        if variants != ["basic"]:
            subtitle += " · " + ", ".join(variants)
        row = Adw.ActionRow(title=escape(package), subtitle=subtitle)
        remove = icon_button("user-trash-symbolic", f"Remove {package} from this set")
        remove.connect("clicked", lambda *_: self.page.window.edit(
            lambda: edit.remove_package(self.model.repo, self.model.ref, package, into=self.name)
            or f"{package} was not in {self.name}"))
        row.add_suffix(remove)
        return row


class SetsPage(SearchablePage):
    def __init__(self, window):
        super().__init__(window, "Search sets, options and packages")
        self.rows: dict[str, SetRow] = {}
        self.plain: dict[str, Gtk.Widget] = {}
        self.groups: dict[str, Adw.PreferencesGroup] = {}
        self.build()
        self.model.listeners.append(self.sync)

    def build(self):
        child = self.content.get_first_child()
        while child is not None:
            self.content.remove(child)
            child = self.content.get_first_child()
        self.rows, self.plain, self.groups = {}, {}, {}
        for name in sorted(self.model.repo.sets):
            category = name.split(".")[0]
            group = self.groups.get(category)
            if group is None:
                group = Adw.PreferencesGroup(title=category.capitalize())
                self.groups[category] = group
                self.content.append(group)
            options = self.model.options(name)
            single = len(options) == 1 and options[0]["name"] == name
            if single:
                # A set that is one choice rather than a switch, e.g. boot.kernel.
                widget = self.option_row(options[0], category)
                self.plain[name] = widget
                group.add(widget)
            else:
                row = SetRow(self, name)
                self.rows[name] = row
                group.add(row.row)
        self.filter()

    def sync(self):
        if set(self.model.repo.sets) != set(self.rows) | set(self.plain):
            self.build()
            return
        for row in self.rows.values():
            row.sync()
        for name, widget in list(self.plain.items()):
            category = name.split(".")[0]
            option = self.model.option(name)
            if option is None:
                continue
            fresh = self.option_row(option, category)
            group = self.groups[category]
            # Keep the row where it was among its siblings.
            group.remove(widget)
            group.add(fresh)
            self.plain[name] = fresh
        self.filter()

    def filter(self):
        needle = self.needle()
        visible: dict[str, bool] = {}
        for name, row in self.rows.items():
            show = not needle or needle in row.searchable()
            row.row.set_visible(show)
            visible[name.split(".")[0]] = visible.get(name.split(".")[0], False) or show
        for name, widget in self.plain.items():
            show = not needle or needle in name.lower()
            widget.set_visible(show)
            visible[name.split(".")[0]] = visible.get(name.split(".")[0], False) or show
        for category, group in self.groups.items():
            group.set_visible(visible.get(category, False))

    # ----------------------------------------------------------- option rows

    def option_row(self, option: dict, parent: str) -> Gtk.Widget:
        name = option["name"]
        label = name[len(parent) + 1:] if name.startswith(parent + ".") else name
        title = escape(label)
        subtitle = escape(humanise(option.get("description", "")))
        kind = option.get("kind")
        value = option.get("value")
        change = lambda new: self.window.edit(lambda: self.model.write_option(name, new))  # noqa: E731

        if kind == "bool":
            row = Adw.SwitchRow(title=title, subtitle=subtitle, active=bool(value))
            row.connect("notify::active", lambda widget, _p: change(widget.get_active()))
            return row

        if kind == "enum":
            choices = [str(choice) for choice in option.get("choices", [])]
            labels = choices if value in choices else [UNSET] + choices
            row = Adw.ComboRow(title=title, subtitle=subtitle, model=Gtk.StringList.new(labels))
            row.set_selected(labels.index(value) if value in labels else 0)

            def picked(widget, _p):
                chosen = labels[widget.get_selected()]
                if chosen != UNSET and chosen != value:
                    change(chosen)

            row.connect("notify::selected", picked)
            return row

        if kind == "enums":
            choices = [str(choice) for choice in option.get("choices", [])]
            current = list(value or [])
            row = Adw.ActionRow(title=title, subtitle=escape(value_text(current)) if current else subtitle)
            box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4, margin_top=10, margin_bottom=10,
                          margin_start=12, margin_end=12)
            checks = {}

            def toggled(_check):
                chosen = [choice for choice in choices if checks[choice].get_active()]
                if chosen != current:
                    popover.popdown()
                    change(chosen)

            for choice in choices:
                check = Gtk.CheckButton(label=choice, active=choice in current)
                checks[choice] = check
                box.append(check)
            apply = Gtk.Button(label="Apply", margin_top=6)
            apply.add_css_class("suggested-action")
            apply.connect("clicked", toggled)
            box.append(apply)
            popover = Gtk.Popover(child=box)
            button = Gtk.MenuButton(icon_name="document-edit-symbolic", popover=popover, valign=Gtk.Align.CENTER,
                                    tooltip_text="Choose")
            button.add_css_class("flat")
            row.add_suffix(button)
            return row

        if kind in ("string", "int", "strings"):
            text = " ".join(map(str, value)) if isinstance(value, list) else ("" if value is None else str(value))
            row = Adw.EntryRow(title=title, text=text, show_apply_button=True)
            if subtitle:
                row.set_tooltip_text(humanise(option.get("description", "")))

            def applied(widget):
                try:
                    change(edit.coerce(option, widget.get_text()))
                except Exception as error:
                    self.window.toast(first_line(error))

            row.connect("apply", applied)
            return row

        return Adw.ActionRow(title=title, subtitle=escape(value_text(value)))


# ----------------------------------------------------------------- packages


class PackagesPage(SearchablePage):
    def __init__(self, window):
        super().__init__(window, "Search selected packages")
        self.group = Adw.PreferencesGroup(title="Selected Packages")
        add = Gtk.Button(valign=Gtk.Align.CENTER)
        add.set_child(Adw.ButtonContent(icon_name="list-add-symbolic", label="Add"))
        add.add_css_class("flat")
        add.connect("clicked", lambda *_: window.add_package(None))
        self.group.set_header_suffix(add)
        self.content.append(self.group)
        self.rows: list[tuple[str, Gtk.Widget]] = []
        self.model.listeners.append(self.sync)
        self.sync()

    def sync(self):
        for _, row in self.rows:
            self.group.remove(row)
        self.rows = []
        packages = self.model.packages()
        excluded = self.model.selection["exclude"]
        self.group.set_description(
            f"{len(packages)} packages for {escape(self.model.ref.name)}"
            + (f", {len(excluded)} kept off" if excluded else ""))
        for name in sorted(packages):
            variants = packages[name]
            origins = self.model.origins(name) or ["a set written as a module"]
            row = Adw.ActionRow(title=escape(name), subtitle=escape("By " + ", ".join(origins)),
                                activatable=True, subtitle_lines=1)
            if variants != ["basic"]:
                label = Gtk.Label(label=", ".join(variants), valign=Gtk.Align.CENTER,
                                  ellipsize=Pango.EllipsizeMode.END, max_width_chars=28)
                label.add_css_class("dim-label")
                label.add_css_class("caption")
                row.add_suffix(label)
            if name not in self.model.repo.packages:
                tag = Gtk.Label(label="nixpkgs", valign=Gtk.Align.CENTER)
                tag.add_css_class("dim-label")
                tag.add_css_class("caption")
                row.add_suffix(tag)
            row.add_suffix(Gtk.Image(icon_name="go-next-symbolic"))
            row.connect("activated", lambda _row, package=name: self.window.show_package(package))
            self.group.add(row)
            self.rows.append((name, row))
        self.filter()

    def filter(self):
        needle = self.needle()
        for name, row in self.rows:
            row.set_visible(not needle or needle in name.lower())


class PackageDialog(Adw.Dialog):
    """What a package is, why it is selected, and what can be done about it."""

    def __init__(self, window, name: str):
        super().__init__(title=name, content_width=520, content_height=560)
        self.window = window
        model = window.model
        repo = model.repo
        entry = repo.packages.get(name)
        meta = (entry or {}).get("meta") or {}
        variants = model.packages().get(name, [])

        page = Adw.PreferencesPage()
        about = Adw.PreferencesGroup(description=escape(meta["description"]) if meta.get("description") else None)
        if entry:
            for variant in entry["variants"]:
                row = Adw.ActionRow(title=escape(variant["name"]), subtitle=escape(variant["file"]), activatable=True)
                row.add_suffix(Gtk.Image(icon_name="document-open-symbolic"))
                row.connect("activated", lambda _r, file=variant["file"]: window.open_file(file))
                about.add(row)
        else:
            about.add(Adw.ActionRow(title="Installed from nixpkgs", subtitle=escape(f"pkgs.{name}, nothing to configure")))
        page.add(about)

        why = Adw.PreferencesGroup(title="Selected By")
        origins = model.origins(name)
        if not variants:
            why.add(Adw.ActionRow(title="Not selected"))
        elif not origins:
            why.add(Adw.ActionRow(title="A set written as a module",
                                  subtitle="Change that set's options, or keep the package off this machine"))
        for origin in origins:
            row = Adw.ActionRow(title=escape(origin[:1].upper() + origin[1:]))
            through = model.selection["sets"].get(origin[4:]) if origin.startswith("set ") else None
            if through:
                row.set_subtitle(escape(f"On through {through}"))
            why.add(row)
        page.add(why)

        actions = Adw.PreferencesGroup()

        def act(label: str, icon: str, change, destructive: bool = False):
            row = Adw.ButtonRow(title=label, start_icon_name=icon)
            if destructive:
                row.add_css_class("destructive-action")

            def activated(*_):
                self.close()
                window.edit(change)

            row.connect("activated", activated)
            actions.add(row)

        for origin in origins:
            if origin.startswith("set "):
                target = origin[4:]
                if repo.sets.get(target, {}).get("kind") == "data":
                    act(f"Remove from the Set {target}", "user-trash-symbolic",
                        lambda target=target: edit.remove_package(repo, model.ref, name, into=target) or "Nothing to remove",
                        destructive=True)
            elif origin == "your shared profile":
                act("Remove from All Your Machines", "user-trash-symbolic",
                    lambda: edit.remove_package(repo, model.ref, name, shared=True) or "Nothing to remove", destructive=True)
            else:
                act("Remove from This Machine", "user-trash-symbolic",
                    lambda: edit.remove_package(repo, model.ref, name) or "Nothing to remove", destructive=True)
        if name in model.selection["exclude"]:
            act("Stop Keeping It Off This Machine", "list-add-symbolic",
                lambda: edit.include_package(repo, model.ref, name) or "Nothing to do")
        elif variants:
            act("Keep Off This Machine", "action-unavailable-symbolic",
                lambda: edit.exclude_package(repo, model.ref, name, variants))
        if entry is None:
            def configure():
                file = edit.new_package(repo, name)
                GLib.idle_add(lambda: window.open_file(str(file.relative_to(repo.root))) and False)
                return f"Created {file.relative_to(repo.root)}"
            act("Give It a Configuration File", "document-new-symbolic", configure)
        page.add(actions)

        view = Adw.ToolbarView()
        view.add_top_bar(Adw.HeaderBar())
        view.set_content(page)
        self.set_child(view)


class AddPackageDialog(Adw.Dialog):
    """Find a package, here or in nixpkgs, and select it."""

    def __init__(self, window, into: str | None):
        super().__init__(title="Add Package", content_width=560, content_height=640)
        self.window = window
        self.model = window.model
        self.serial = 0
        self.timeout = 0

        repo = self.model.repo
        self.destinations: list[tuple[str, dict]] = [
            (f"This machine ({self.model.ref.machine})", {"shared": False}),
            ("All my machines", {"shared": True}),
        ]
        for name, entry in sorted(repo.sets.items()):
            if entry["kind"] == "data":
                self.destinations.append((f"The set {name}", {"into": name}))
        selected = 1 if self.model.shared else 0
        if into is not None:
            selected = next((index for index, (_, target) in enumerate(self.destinations)
                             if target.get("into") == into), selected)

        box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12, margin_top=12, margin_bottom=12,
                      margin_start=12, margin_end=12)
        self.entry = Gtk.SearchEntry(placeholder_text="Name of a package, e.g. ripgrep", hexpand=True)
        self.entry.connect("search-changed", self.changed)
        self.entry.connect("activate", lambda *_: self.search_now())
        box.append(self.entry)

        target_group = Adw.PreferencesGroup()
        self.target = Adw.ComboRow(title="Add to", model=Gtk.StringList.new([label for label, _ in self.destinations]))
        self.target.set_selected(selected)
        target_group.add(self.target)
        box.append(target_group)

        self.searching = Gtk.Box(spacing=10, halign=Gtk.Align.CENTER, visible=False)
        spinner = Adw.Spinner()
        spinner.set_size_request(20, 20)
        self.searching.append(spinner)
        note = Gtk.Label(label="Searching nixpkgs. The first search after an update takes a few minutes.")
        note.add_css_class("dim-label")
        note.add_css_class("caption")
        self.searching.append(note)
        box.append(self.searching)

        self.results = Gtk.ListBox(selection_mode=Gtk.SelectionMode.NONE, visible=False)
        self.results.add_css_class("boxed-list")
        self.hint = Adw.StatusPage(icon_name="system-search-symbolic", title="Find a Package",
                                   description="Packages configured here and everything in nixpkgs", vexpand=True)
        self.hint.add_css_class("compact")
        holder = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        holder.append(self.results)
        holder.append(self.hint)
        box.append(scrolled(holder))

        view = Adw.ToolbarView()
        view.add_top_bar(Adw.HeaderBar())
        view.set_content(box)
        self.set_child(view)
        self.entry.grab_focus()

    def changed(self, *_):
        if self.timeout:
            GLib.source_remove(self.timeout)
        self.timeout = GLib.timeout_add(450, self.search_now)

    def search_now(self):
        if self.timeout:
            GLib.source_remove(self.timeout)
            self.timeout = 0
        term = self.entry.get_text().strip()
        self.serial += 1
        serial = self.serial
        if len(term) < 2:
            self.show_results([], term)
            return False
        local = []
        for name, entry in sorted(self.model.repo.packages.items()):
            if term.lower() in name.lower():
                description = (entry.get("meta") or {}).get("description", "") or "Configured under src/"
                local.append((name, description, "configured here"))
        self.show_results(local, term, searching=True)
        exact: list[tuple[str, str, str]] = []

        def lookup():
            # An exact attribute name is answered at once, without the full search.
            result = subprocess.run(
                ["nix", "eval", "--json", f"nixpkgs#{term}", "--apply",
                 'p: { version = p.version or ""; description = p.meta.description or ""; }'],
                capture_output=True, text=True)
            return json.loads(result.stdout) if result.returncode == 0 else None

        def found(entry):
            if serial != self.serial or entry is None or any(name == term for name, _, _ in local):
                return
            exact.append((term, entry.get("description", ""), entry.get("version", "")))
            self.show_results(local + exact, term, searching=self.searching.get_visible())

        run_async(lookup, found, lambda _error: None)

        def work():
            result = subprocess.run(["nix", "search", "nixpkgs", term, "--json"], capture_output=True, text=True)
            if result.returncode != 0:
                raise RuntimeError(result.stderr.strip().splitlines()[-1] if result.stderr.strip() else "search failed")
            found = json.loads(result.stdout or "{}")
            rows = []
            for attribute, entry in found.items():
                name = attribute.split(".", 2)[2] if attribute.count(".") >= 2 else attribute
                rows.append((name, entry.get("description", ""), entry.get("version", "")))
            rows.sort(key=lambda row: (term.lower() not in row[0].lower(), len(row[0]), row[0]))
            return rows[:60]

        def done(rows):
            if serial != self.serial:
                return
            seen = {name for name, _, _ in local + exact}
            self.show_results(local + exact + [row for row in rows if row[0] not in seen], term)

        def failed(error):
            if serial == self.serial:
                self.show_results(local + exact, term)
                self.window.toast(f"Searching nixpkgs failed: {first_line(error)}")

        run_async(work, done, failed)
        return False

    def show_results(self, rows, term: str, searching: bool = False):
        self.searching.set_visible(searching)
        child = self.results.get_first_child()
        while child is not None:
            self.results.remove(child)
            child = self.results.get_first_child()
        selected = self.model.packages()
        for name, description, extra in rows:
            row = Adw.ActionRow(title=escape(name), subtitle=escape(description), subtitle_lines=2)
            if extra:
                tag = Gtk.Label(label=extra, valign=Gtk.Align.CENTER)
                tag.add_css_class("dim-label")
                tag.add_css_class("caption")
                row.add_suffix(tag)
            button = Gtk.Button(label="Add", valign=Gtk.Align.CENTER)
            button.connect("clicked", lambda button, package=name: self.add(package, button))
            if name in selected:
                button.set_tooltip_text("Already selected for this profile")
            row.add_suffix(button)
            self.results.append(row)
        self.results.set_visible(bool(rows))
        self.hint.set_visible(not rows and not searching)
        if len(term) >= 2 and not rows and not searching:
            self.hint.set_title("Nothing Found")
            self.hint.set_description(f"No package matches “{term}”")
        else:
            self.hint.set_title("Find a Package")
            self.hint.set_description("Packages configured here and everything in nixpkgs")

    def add(self, package: str, button: Gtk.Button):
        _, target = self.destinations[self.target.get_selected()]
        button.set_sensitive(False)
        model = self.model

        def change():
            return edit.add_package(model.repo, model.ref, package, verify=False, **target)

        def done(_):
            button.set_label("Added")

        self.window.edit(change, done=done, failed=lambda _error: button.set_sensitive(True))


# ------------------------------------------------------------------ updates


class UpdatesPage(Gtk.Box):
    def __init__(self, window):
        super().__init__(orientation=Gtk.Orientation.VERTICAL)
        self.window = window
        self.model = window.model
        self.busy = False
        self.content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=24)
        self.append(scrolled(clamp(self.content)))
        self.rows: dict[str, tuple[Adw.ActionRow, Gtk.Label, Gtk.Button]] = {}
        self.statuses: dict[str, update.Status] = {}

        buttons = Gtk.Box(spacing=8, valign=Gtk.Align.CENTER)
        self.check_button = Gtk.Button(label="Check")
        self.check_button.connect("clicked", lambda *_: self.check())
        self.update_button = Gtk.Button(label="Update All")
        self.update_button.add_css_class("suggested-action")
        self.update_button.connect("clicked", lambda *_: self.run([]))
        buttons.append(self.check_button)
        buttons.append(self.update_button)
        self.spinner = Adw.Spinner(visible=False)
        buttons.prepend(self.spinner)

        self.packages_group = Adw.PreferencesGroup(
            title="Packages", description="Pinned versions that packages keep for themselves")
        self.packages_group.set_header_suffix(buttons)
        self.system_group = Adw.PreferencesGroup(
            title="System", description="Flake inputs the whole configuration is built from")
        # The latest update, for as long as it can still be taken back.
        self.latest_group = Adw.PreferencesGroup(title="Latest Update", visible=False)
        self.latest_row = Adw.ActionRow(subtitle_lines=3)
        back = Gtk.Button(label="Take Back", valign=Gtk.Align.CENTER,
                          tooltip_text="Put the versions back to what they were before this update")
        back.connect("clicked", lambda *_: self.take_back())
        self.latest_row.add_suffix(back)
        self.latest_group.add(self.latest_row)
        self.content.append(self.latest_group)
        self.content.append(self.packages_group)
        self.content.append(self.system_group)
        self.model.listeners.append(self.sync)
        self.sync()

    @staticmethod
    def key(target: update.Target) -> str:
        return f"{target.kind}:{target.owner or ''}:{target.name}"

    def current(self, target: update.Target) -> str:
        if target.kind == "input":
            locked = self.model.repo.flake_inputs().get(target.name, {}).get("locked", {})
            return f"{locked.get('rev', '')[:10]} · {update._date(locked.get('lastModified'))}"
        try:
            pinned = json.loads((target.directory / target.spec.get("file", "release.json")).read_text())
            return str(pinned.get("version", ""))
        except (OSError, ValueError):
            return target.spec.get("type", "")

    def sync(self):
        for row, _, _ in self.rows.values():
            parent = self.packages_group if row.owned else self.system_group
            parent.remove(row)
        self.rows = {}
        latest = update.last_update(self.model.repo)
        self.latest_group.set_visible(latest is not None)
        if latest is not None:
            waiting = update.pending(self.model.repo) is not None
            self.latest_row.set_title(f"Update of {update.when(latest)}" + (" · not applied yet" if waiting else ""))
            self.latest_row.set_subtitle(escape("; ".join(latest.get("changes", []))))
        try:
            targets = self.model.update_targets()
        except Exception as error:
            self.window.toast(first_line(error))
            return
        for target in targets:
            title = target.name if not target.owner or target.owner == target.name else f"{target.owner}"
            subtitle = self.current(target)
            if target.owner and target.owner != target.name:
                subtitle = f"{target.name} · {subtitle}"
            row = Adw.ActionRow(title=escape(title), subtitle=escape(subtitle))
            row.owned = bool(target.owner)
            status = Gtk.Label(valign=Gtk.Align.CENTER)
            status.add_css_class("caption")
            row.add_suffix(status)
            button = Gtk.Button(label="Update", valign=Gtk.Align.CENTER, visible=False)
            button.add_css_class("flat")
            button.connect("clicked", lambda _b, target=target: self.run([target.owner or target.name]))
            row.add_suffix(button)
            (self.packages_group if row.owned else self.system_group).add(row)
            self.rows[self.key(target)] = (row, status, button)
            known = self.statuses.get(self.key(target))
            if known is not None:
                self.show_status(target, known)

    def show_status(self, target: update.Target, status: update.Status):
        entry = self.rows.get(self.key(target))
        if entry is None:
            return
        _, label, button = entry
        for name in ("success", "warning", "dim-label"):
            label.remove_css_class(name)
        if status.outdated:
            label.set_label(f"{status.latest} available")
            label.add_css_class("warning")
        elif status.outdated is False:
            label.set_label("Up to date")
            label.add_css_class("success")
        else:
            label.set_label(status.note.split(" (")[0][:40] or "Unknown")
            label.add_css_class("dim-label")
        button.set_visible(bool(status.outdated))

    def take_back(self):
        if self.busy:
            return
        self.set_busy(True)

        def done(_restored):
            self.set_busy(False)
            self.statuses = {}
            self.window.toast("The update is taken back")
            self.model.refresh()

        run_async(lambda: update.undo(self.model.repo), done,
                  lambda error: (self.set_busy(False), self.window.toast(first_line(error))))

    def set_busy(self, busy: bool):
        self.busy = busy
        self.spinner.set_visible(busy)
        self.check_button.set_sensitive(not busy)
        self.update_button.set_sensitive(not busy)

    def check(self):
        if self.busy:
            return
        self.set_busy(True)
        repo = self.model.repo
        targets = self.model.update_targets()

        def work():
            with ThreadPoolExecutor(max_workers=8) as pool:
                return list(pool.map(lambda target: update.check(repo, target), targets))

        def done(statuses):
            self.set_busy(False)
            outdated = 0
            for target, status in zip(targets, statuses):
                self.statuses[self.key(target)] = status
                self.show_status(target, status)
                outdated += bool(status.outdated)
            self.window.toast("Everything is up to date" if not outdated
                              else f"{outdated} update{'s' if outdated != 1 else ''} available")

        run_async(work, done, lambda error: (self.set_busy(False), self.window.toast(first_line(error))))

    def run(self, names: list[str]):
        if self.busy:
            return
        self.set_busy(True)
        repo = self.model.repo

        def work():
            chosen = update.select(repo, names)
            return update.update(repo, chosen, everything=not names)

        def done(changes):
            self.set_busy(False)
            self.statuses = {}
            self.model.refresh()
            if changes:
                self.window.toast(f"Updated {len(changes)}: " + "; ".join(changes)[:120])
            else:
                self.window.toast("Already up to date")

        run_async(work, done, lambda error: (self.set_busy(False), self.window.toast(first_line(error))))
