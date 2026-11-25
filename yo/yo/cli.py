"""yo on the command line."""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path

from . import __version__, edit, system, term, update
from .failure import Failed, Failure
from .nixdata import EditError, NotData
from .repo import (
    CACHE_PROBLEM, ProfileRef, Repo, YoError, cache_dir, find_root, foreign_cache_entries, nix_cache_dir,
    static_selection,
)
from .term import bold, dim, good, warn


class Context:
    """What a command needs to know, worked out on first use."""

    def __init__(self, args: argparse.Namespace):
        self.args = args
        self._repo: Repo | None = None
        self._profile: ProfileRef | None = None
        self._state: tuple[dict | None, str] | None = None
        self.cache_usable = True  # False once Nix's cache was found to need repair

    @property
    def repo(self) -> Repo:
        if self._repo is None:
            self._repo = Repo(find_root(self.args.root))
        return self._repo

    @property
    def profile(self) -> ProfileRef:
        if self._profile is None:
            self._profile = self.repo.resolve_profile(self.args.profile)
        return self._profile

    def state(self, exact: bool = False) -> tuple[dict | None, str]:
        """The profile's evaluated state and where it comes from.

        Evaluating the tree takes a couple of seconds and is remembered until
        the tree changes. When the tree does not evaluate, fall back to what
        the running system says, so that yo stays usable for fixing it.
        """
        if self._state is None:
            try:
                if not self.cache_usable:
                    # Already explained; Nix would only fail with the same complaint.
                    raise YoError(f"Nix's cache needs repair first: yo doctor --fix")
                self._state = (self.repo.evaluated_state(self.profile), "tree")
            except YoError as error:
                if exact:
                    raise
                if self.cache_usable:
                    term.error(str(error))
                state, origin = self.repo.best_state(self.profile)
                self._state = (state, "running" if state else "none")
        return self._state

    def forget_state(self):
        self._state = None


def stale_note(origin: str) -> str | None:
    if origin == "running":
        return "Shown for the running system, because the working tree could not be evaluated."
    if origin == "none":
        return ("Shown from the profile and set files only, because the working tree could not be evaluated; "
                "sets written as modules may add more.")
    return None


# ------------------------------------------------------------------- display


def option_value(state: dict | None, name: str):
    for option in (state or {}).get("options", []):
        if option["name"] == name:
            return option
    return None


def set_description(repo: Repo, name: str, state: dict | None) -> str:
    entry = repo.sets[name]
    if entry.get("description"):
        return entry["description"]
    option = option_value(state, name + ".enable") or option_value(state, name)
    text = (option or {}).get("description", "")
    for prefix in ("Whether to enable ", "Whether to ", "Enable "):
        if text.startswith(prefix):
            text = text[len(prefix):]
            break
    return text.rstrip(".")


def set_is_on(repo: Repo, ref: ProfileRef, name: str, state: dict | None, selection: dict) -> bool | None:
    """True or False, or None for a set that is not an on/off switch."""
    option = option_value(state, name + ".enable")
    if option is not None and "value" in option:
        return bool(option["value"])
    if repo.sets[name]["kind"] == "data":
        return name in selection["sets"]
    if state is not None:
        return None
    return name in selection["sets"] or None


def format_value(value) -> str:
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, list):
        return " ".join(map(str, value)) if value else "(none)"
    if value is None:
        return "(unset)"
    return str(value)


def cmd_status(ctx: Context):
    repo = ctx.repo
    rows = [(bold("Configuration"), str(repo.root))]
    try:
        ref = ctx.profile
    except YoError as error:
        ref = None
        rows.append((bold("Profile"), warn(str(error).splitlines()[0])))
    if ref:
        rows.append((bold("Profile"), f"{ref.name}  {dim(f'user {ref.user}, machine {ref.machine}')}"))

    running = repo.running_state()
    try:
        current = next((entry for entry in system.generations() if entry.get("current")), None)
    except YoError:
        current = None
    if current:
        rows.append((bold("System"),
                     f"generation {current['generation']}, NixOS {current.get('nixosVersion', '?')}, "
                     f"built {current.get('date', '?')}"))
    if running and ref and running.get("profile", {}).get("name") not in (None, ref.name):
        rows.append(("", warn(f"the running system was built from {running['profile']['name']}")))

    sync = repo.in_sync()
    if sync is True:
        rows.append((bold("State"), good("the running system matches the working tree")))
    elif sync is False:
        rows.append((bold("State"), warn("changes not applied yet") + dim("  (yo diff to review, yo switch to apply)")))
    else:
        rows.append((bold("State"), dim("unknown: this system was not switched with yo yet (yo switch)")))

    if ref:
        state, origin = ctx.state()
        selection = static_selection(repo, ref)
        on = [name for name in repo.sets if set_is_on(repo, ref, name, state, selection)]
        packages = state["packages"] if state else selection["packages"]
        approximate = "" if origin == "tree" else dim("  (as of the running system)" if origin == "running" else "  (from data files only)")
        rows.append((bold("Sets"), f"{len(on)} on, of {len(repo.sets)}{approximate}"))
        rows.append((bold("Packages"), f"{len(packages)} selected"))

    git = subprocess.run(["git", "-C", str(repo.root), "status", "--porcelain"], capture_output=True, text=True)
    if git.returncode == 0:
        changed = len([line for line in git.stdout.splitlines() if line.strip()])
        rows.append((bold("Git"), f"{changed} uncommitted changes" if changed else "clean"))
    print("\n".join(term.table(rows, indent="")))


def cmd_list(ctx: Context):
    what = ctx.args.what
    if what in ("sets", "set"):
        list_sets(ctx)
    elif what in ("packages", "package", "pkgs"):
        list_packages(ctx)
    elif what in ("profiles", "profile"):
        list_profiles(ctx)
    else:
        list_sets(ctx)
        print()
        list_packages(ctx)


def list_profiles(ctx: Context):
    repo = ctx.repo
    try:
        active = ctx.profile
    except YoError:
        active = None
    running = (repo.running_state() or {}).get("profile", {}).get("name")
    rows = []
    for ref in repo.profiles():
        marks = []
        if active and ref == active:
            marks.append("this machine")
        if ref.name == running:
            marks.append("running")
        rows.append((good("●") if ref == active else "○", bold(ref.name),
                     f"profiles/{ref.user}/{ref.machine}", dim(", ".join(marks))))
    print("\n".join(term.table(rows, indent="")) or "No profiles yet. Create one with: yo init")


def list_sets(ctx: Context):
    repo, ref = ctx.repo, ctx.profile
    state, origin = ctx.state()
    selection = static_selection(repo, ref)
    only_on = getattr(ctx.args, "on", False)
    category = None
    limit = max(term.width() - 44, 30)
    for name in sorted(repo.sets):
        on = set_is_on(repo, ref, name, state, selection)
        if only_on and not on:
            continue
        head = name.split(".")[0]
        if head != category:
            if category is not None:
                print()
            print(bold(head))
            category = head
        mark = good("●") if on else ("○" if on is False else dim("◆"))
        why = selection["sets"].get(name, "")
        if on and not why:
            why = "a set module" if repo.sets[name]["kind"] == "data" or state else ""
        description = term.shorten(set_description(repo, name, state), limit)
        print(f"  {mark} {name:<26} {description}" + (dim(f"  [{why}]") if why and on else ""))
    hint = stale_note(origin)
    if hint:
        print()
        term.note(hint)


def package_origins(repo: Repo, selection: dict, name: str, variant: str) -> list[str]:
    return selection["packages"].get(name, {}).get(variant, [])


def list_packages(ctx: Context):
    repo, ref = ctx.repo, ctx.profile
    state, origin = ctx.state()
    selection = static_selection(repo, ref)
    if state:
        effective = state["packages"]
    else:
        effective = {name: sorted(variants) for name, variants in selection["packages"].items()}
    rows = []
    for name in sorted(effective):
        variants = effective[name]
        origins: list[str] = []
        for variant in variants:
            for where in package_origins(repo, selection, name, variant):
                if where not in origins:
                    origins.append(where)
        source = "src" if name in repo.packages else "nixpkgs"
        shown = "" if variants == ["basic"] else " ".join(variants)
        rows.append((bold(name), shown, dim(source), dim(", ".join(origins) or "a set module")))
    print("\n".join(term.table(rows, indent="")))
    print()
    term.note(f"{len(rows)} packages selected for {ref.name}.")
    hint = stale_note(origin)
    if hint:
        term.note(hint)


def cmd_show(ctx: Context):
    repo = ctx.repo
    name = ctx.args.name
    normal = name.replace("/", ".")
    if normal in repo.sets:
        return show_set(ctx, normal)
    state, _ = ctx.state()
    if name in repo.packages or name in (state or {}).get("packages", {}):
        return show_package(ctx, name)
    if option_value(state, normal) is not None:
        return show_option(ctx, normal)
    selection = static_selection(repo, ctx.profile)
    if name in selection["packages"]:
        return show_package(ctx, name)
    known = list(repo.sets) + list(repo.packages)
    raise YoError(f"There is no set, package or option called {name!r}.{edit.suggest(normal, known)}")


def show_set(ctx: Context, name: str):
    repo, ref = ctx.repo, ctx.profile
    state, origin = ctx.state()
    selection = static_selection(repo, ref)
    entry = repo.sets[name]
    on = set_is_on(repo, ref, name, state, selection)
    print(bold(name) + (f"  {set_description(repo, name, state)}" if set_description(repo, name, state) else ""))
    rows = [("file", entry["file"] + dim("  (data: yo can edit it)" if entry["kind"] == "data" else "  (a module: edit it by hand)"))]
    if on is not None:
        why = selection["sets"].get(name)
        rows.append(("state", (good("on") if on else "off") + (dim(f"  through {why}") if on and why else "")))
    if entry["kind"] == "data":
        packages = [package if variants == ["basic"] else f"{package}[{' '.join(variants)}]"
                    for package, variants in sorted(entry["packages"].items())]
        if packages:
            rows.append(("packages", " ".join(packages)))
        if entry["sets"]:
            rows.append(("switches on", " ".join(entry["sets"])))
        if entry["config"]:
            rows.append(("also", "sets system options (see the file)"))
    options = [option for option in (state or {}).get("options", [])
               if option["name"] == name or option["name"].startswith(name + ".")]
    for line in term.table(rows):
        print(line)
    if options:
        print("  options")
        option_rows = []
        for option in options:
            choices = dim(" | ".join(map(str, option.get("choices", [])))) if option.get("choices") else dim(option.get("kind", ""))
            option_rows.append((option["name"], "= " + format_value(option.get("value")), choices))
        for line in term.table(option_rows, indent="    "):
            print(line)
    hint = stale_note(origin)
    if hint:
        term.note(hint)


def show_package(ctx: Context, name: str):
    repo, ref = ctx.repo, ctx.profile
    state, origin = ctx.state()
    selection = static_selection(repo, ref)
    entry = repo.packages.get(name)
    meta = (entry or {}).get("meta") or {}
    print(bold(name) + (f"  {meta['description']}" if meta.get("description") else ""))
    rows = []
    if entry:
        for variant in entry["variants"]:
            rows.append(("variant", f"{variant['name']}  {dim(variant['file'])}"))
        if "basic" not in {variant["name"] for variant in entry["variants"]}:
            rows.append(("variant", f"basic  {dim('pkgs.' + name + ' (the default)')}"))
    else:
        rows.append(("source", f"pkgs.{name} from nixpkgs {dim('(no directory under src/: nothing to configure)')}"))
    active = (state or {}).get("packages", {}).get(name) if state else sorted(selection["packages"].get(name, {}))
    if active:
        for variant in active:
            origins = package_origins(repo, selection, name, variant) or ["a set module"]
            rows.append(("selected", f"{variant}  {dim('by ' + ', '.join(origins))}"))
    else:
        rows.append(("selected", "no"))
    if name in selection["exclude"]:
        rows.append(("excluded", " ".join(selection["exclude"][name])))
    members = [set_name for set_name, set_entry in sorted(repo.sets.items())
               if name in set_entry.get("packages", {})]
    if members:
        rows.append(("in sets", " ".join(members)))
    if meta.get("homepage"):
        rows.append(("homepage", meta["homepage"]))
    for target in update.targets(repo):
        if target.owner == name:
            rows.append(("updates", target.label))
    for line in term.table(rows):
        print(line)
    hint = stale_note(origin)
    if hint:
        term.note(hint)


def show_option(ctx: Context, name: str):
    state, origin = ctx.state()
    option = option_value(state, name)
    print(bold(name))
    rows = [("value", format_value(option.get("value")))]
    if "default" in option:
        rows.append(("default", format_value(option["default"])))
    rows.append(("type", option.get("type", "")))
    if option.get("choices"):
        rows.append(("choices", " ".join(map(str, option["choices"]))))
    if option.get("description"):
        rows.append(("about", option["description"]))
    for line in term.table(rows):
        print(line)


def cmd_why(ctx: Context):
    repo, ref = ctx.repo, ctx.profile
    name = ctx.args.package
    state, origin = ctx.state()
    selection = static_selection(repo, ref)
    active = (state or {}).get("packages", {}).get(name) if state else sorted(selection["packages"].get(name, {}))
    if not active:
        excluded = selection["exclude"].get(name)
        if excluded:
            print(f"{name} is excluded in the profile ({' '.join(excluded)}).")
        else:
            print(f"{name} is not selected for {ref.name}.")
        return 1
    for variant in active:
        origins = package_origins(repo, selection, name, variant)
        label = name if variant == "basic" else f"{name} ({variant})"
        if not origins:
            print(f"{bold(label)} is selected by a set written as a module.")
            for set_name, entry in sorted(repo.sets.items()):
                if entry["kind"] != "module":
                    continue
                text = (repo.root / entry["file"]).read_text()
                if name in text:
                    print(f"  {dim('mentioned in')} {entry['file']}")
            continue
        print(f"{bold(label)} is selected by:")
        for where in origins:
            chain = where
            if where.startswith("set "):
                through = selection["sets"].get(where[4:])
                if through:
                    chain += dim(f"  (on through {through})")
            print(f"  {chain}")
    return 0


def cmd_options(ctx: Context):
    state, origin = ctx.state(exact=True)
    prefix = (ctx.args.prefix or "").replace("/", ".")
    rows = []
    for option in state["options"]:
        if prefix and not option["name"].startswith(prefix):
            continue
        choices = " | ".join(map(str, option.get("choices", []))) or option.get("kind", "")
        rows.append((option["name"], format_value(option.get("value")), dim(choices)))
    print("\n".join(term.table(rows, indent="")) or f"No options under {prefix!r}.")
    hint = stale_note(origin)
    if hint:
        term.note(hint)


def cmd_search(ctx: Context):
    repo = ctx.repo
    needle = ctx.args.term.lower()
    hits = []
    for name, entry in sorted(repo.sets.items()):
        text = f"{name} {entry.get('description', '')}".lower()
        members = [package for package in entry.get("packages", {}) if needle in package.lower()]
        if needle in text or members:
            extra = f" (has {', '.join(members)})" if members and needle not in text else ""
            hits.append((dim("set"), bold(name), entry.get("description", "") + extra))
    for name, entry in sorted(repo.packages.items()):
        description = (entry.get("meta") or {}).get("description", "")
        if needle in name.lower() or needle in description.lower():
            hits.append((dim("src"), bold(name), description or " ".join(v["name"] for v in entry["variants"])))
    if hits:
        print("In this configuration:")
        for line in term.table(hits):
            print(line)
    if ctx.args.local:
        return
    term.note("Searching nixpkgs (the first search after an update takes a few minutes)...")
    result = subprocess.run(
        ["nix", "search", "nixpkgs", ctx.args.term, "--json"], capture_output=True, text=True)
    if result.returncode != 0:
        raise YoError("Searching nixpkgs failed:\n" + result.stderr.strip()[-1200:])
    import json
    found = json.loads(result.stdout or "{}")
    rows = []
    for attribute, entry in sorted(found.items(), key=lambda item: (needle not in item[0].lower(), len(item[0]))):
        name = attribute.split(".", 2)[-1] if attribute.count(".") >= 2 else attribute
        rows.append((bold(name), dim(entry.get("version", "")),
                     term.shorten(entry.get("description", ""), max(term.width() - 50, 30))))
    if rows:
        print(f"In nixpkgs ({len(rows)} found" + (", first 25 shown" if len(rows) > 25 else "") + "):")
        for line in term.table(rows[:25]):
            print(line)
        term.note("Add one with: yo add <name>")
    elif not hits:
        print(f"Nothing found for {ctx.args.term!r}.")


# ------------------------------------------------------------------- editing


def after_edit(ctx: Context, messages: list[str]):
    for message in messages:
        print(message)
    if any(not message.startswith(("Nothing", " ")) and "already" not in message for message in messages):
        term.note("Apply with: yo switch")


def cmd_enable(ctx: Context, on: bool = True):
    state, _ = ctx.state()
    messages = [edit.switch_set(ctx.repo, ctx.profile, name, on, shared=ctx.args.shared, state=state)
                for name in ctx.args.sets]
    after_edit(ctx, messages)


def cmd_disable(ctx: Context):
    cmd_enable(ctx, on=False)


def cmd_option(ctx: Context):
    name = ctx.args.name.replace("/", ".")
    if name.startswith("modules."):
        name = name[len("modules."):]
    state, origin = ctx.state()
    if ctx.args.unset:
        file = edit.clear_option(ctx.repo, ctx.profile, name, shared=ctx.args.shared)
        return after_edit(ctx, [f"{name} is no longer set in the profile" if file else f"{name} was not set in the profile"])
    if not ctx.args.value:
        if option_value(state, name) is None:
            known = [option["name"] for option in state["options"]]
            raise YoError(f"There is no option {name!r}.{edit.suggest(name, known)}")
        return show_option(ctx, name)
    option = option_value(state, name)
    if option is None and state is not None:
        known = [entry["name"] for entry in state["options"]]
        raise YoError(f"There is no option {name!r}.{edit.suggest(name, known)}")
    value = edit.coerce(option, " ".join(ctx.args.value))
    edit.write_option(ctx.repo, ctx.profile, name, value, shared=ctx.args.shared)
    where = "your shared profile" if ctx.args.shared else f"the {ctx.profile.machine} profile"
    after_edit(ctx, [f"{name} = {format_value(value)} in {where}"])


def cmd_add(ctx: Context):
    repo, ref = ctx.repo, ctx.profile
    variants = ctx.args.variant or ["basic"]
    messages = []
    for name in ctx.args.packages:
        if not ctx.args.to:
            # Already there through a set? Then the profile need not repeat it.
            state, _ = ctx.state()
            active = (state or {}).get("packages", {}).get(name, [])
            if all(variant in active for variant in variants):
                selection = static_selection(repo, ref)
                origins = sorted({where for variant in variants
                                  for where in package_origins(repo, selection, name, variant)})
                messages.append(f"{name} is already selected" + (f" by {', '.join(origins)}" if origins else ""))
                continue
        messages.append(edit.add_package(repo, ref, name, variants, into=ctx.args.to, shared=ctx.args.shared,
                                         verify=not ctx.args.no_verify))
        ctx.forget_state()
    after_edit(ctx, messages)


def cmd_rm(ctx: Context):
    repo, ref = ctx.repo, ctx.profile
    messages = []
    for name in ctx.args.packages:
        message = edit.remove_package(repo, ref, name, ctx.args.variant or None,
                                      into=ctx.args.from_set, shared=ctx.args.shared)
        if message is None and not ctx.args.from_set and not ctx.args.shared:
            # Perhaps it sits in the shared profile instead.
            message = edit.remove_package(repo, ref, name, ctx.args.variant or None, shared=True)
        if message is None:
            selection = static_selection(repo, ref)
            origins = sorted({where for wheres in selection["packages"].get(name, {}).values() for where in wheres})
            if origins:
                message = (f"Nothing removed: {name} comes from {', '.join(origins)}.\n"
                           f"  Take it out there (yo rm {name} --from <set>), or keep it off this machine: yo exclude {name}")
            else:
                message = f"Nothing removed: {name} is not selected by the profile or a data set."
        messages.append(message)
    after_edit(ctx, messages)


def cmd_exclude(ctx: Context):
    after_edit(ctx, [edit.exclude_package(ctx.repo, ctx.profile, name, ctx.args.variant or None, shared=ctx.args.shared)
                     for name in ctx.args.packages])


def cmd_include(ctx: Context):
    messages = []
    for name in ctx.args.packages:
        message = edit.include_package(ctx.repo, ctx.profile, name, shared=ctx.args.shared)
        messages.append(message or f"Nothing to do: {name} is not excluded")
    after_edit(ctx, messages)


def cmd_new(ctx: Context):
    repo = ctx.repo
    kind = ctx.args.kind
    if kind == "set":
        for package in ctx.args.packages:
            if not ctx.args.no_verify:
                edit.check_package(repo, package, ["basic"])
        file = edit.new_set(repo, ctx.args.name, ctx.args.description or "", ctx.args.packages)
        name = ctx.args.name.replace("/", ".")
        print(f"Created {file.relative_to(repo.root)}")
        term.note(f"Switch it on with: yo enable {name}")
    elif kind == "package":
        file = edit.new_package(repo, ctx.args.name, ctx.args.variant, directory=ctx.args.dir)
        print(f"Created {file.relative_to(repo.root)}")
        term.note(f"Select it with: yo add {ctx.args.name}"
                  + (f" --variant {ctx.args.variant}" if ctx.args.variant != "basic" else ""))
    else:
        new_profile(ctx, ctx.args.user, ctx.args.machine)


def new_profile(ctx: Context, user: str | None, machine: str | None):
    repo = ctx.repo
    import socket
    user = user or term.ask("User name:", os.environ.get("USER", ""))
    machine = machine or term.ask("Name for this machine:", "")
    if not user or not machine:
        raise YoError("A profile needs a user and a machine name: yo new profile <user> <machine>")
    details = {}
    if not (repo.root / "profiles" / user).exists():
        details["host"] = term.ask("Host name:", socket.gethostname() or machine)
        details["full_name"] = term.ask("Full name:", "")
        details["email"] = term.ask("Email:", "")
        details["copy_from"] = getattr(ctx.args, "like", None)
    notes = edit.new_profile(repo, user, machine, **details)
    ref = ProfileRef(user, machine)
    print(f"Created the profile {bold(ref.name)}:")
    for note in notes:
        print(f"  {note}")
    if sys.stdin.isatty() and term.confirm(f"Is {ref.name} the profile of this machine?", default=True):
        repo.remember_profile(ref)
    term.note("Next: yo list sets, yo enable <set>, then yo switch")


def cmd_init(ctx: Context):
    repo = ctx.repo
    print(f"This configuration lives in {repo.root}.")
    known = repo.profiles()
    if known:
        print("Existing profiles: " + ", ".join(ref.name for ref in known))
    new_profile(ctx, ctx.args.user, ctx.args.machine)


def cmd_edit(ctx: Context):
    repo = ctx.repo
    name = ctx.args.name
    normal = name.replace("/", ".")
    if name in ("profile", "machine"):
        file = repo.profile_file(ctx.profile)
    elif name == "shared":
        file = repo.profile_file(ctx.profile, shared=True)
    elif name == "pinned":
        file = repo.profile_file(ctx.profile).with_name("pinned.nix")
    elif normal in repo.sets:
        file = repo.set_file(normal)
    elif name in repo.packages:
        variants = repo.packages[name]["variants"]
        file = repo.root / (variants[0]["file"] if variants else f"src/{name}")
    else:
        raise YoError(f"Nothing called {name!r} to edit. Try a set, a package under src/, "
                      "or one of: profile, shared, pinned")
    editor = os.environ.get("VISUAL") or os.environ.get("EDITOR")
    if not editor or not sys.stdout.isatty():
        print(file)
        return
    import shlex
    subprocess.run([*shlex.split(editor), str(file)])


# -------------------------------------------------------------------- system


def print_progress(line: str):
    """What is being built and what Nix warns about. Errors are told at the end, as a whole."""
    if line.startswith(("building ", "warning: ", "evaluation warning")):
        print(dim("  " + term.shorten(line, term.width() - 4)), flush=True)


def summarise_changes(changes: list[system.Change], limit: int | None = 40):
    if not changes:
        print("No package changes.")
        return
    added = [change for change in changes if change.kind == "added"]
    removed = [change for change in changes if change.kind == "removed"]
    changed = [change for change in changes if change.kind == "changed"]
    print(f"{len(changed)} changed, {len(added)} added, {len(removed)} removed:")
    rows = []
    for change in changed:
        rows.append((warn("~"), change.name, f"{change.old} -> {change.new}" if change.old != change.new else change.new))
    for change in added:
        rows.append((good("+"), change.name, change.new))
    for change in removed:
        rows.append((term.bad("-"), change.name, change.old))
    shown = rows if limit is None else rows[:limit]
    for line in term.table(shown):
        print(line)
    if limit is not None and len(rows) > limit:
        term.note(f"  ... and {len(rows) - limit} more (yo diff --all)")


def report_failure(ctx: Context, failure: Failure):
    """Say what failed: the gist first, then where to look and what can be done."""
    def say(text: str = ""):
        print(text, file=sys.stderr)

    if getattr(ctx.args, "trace", False) and failure.phase == "evaluate":
        for line in failure.log.splitlines():
            say(dim(line))
        say()
    say(term.style(failure.title, "bold", "red"))
    say(failure.summary)
    if failure.message:
        say()
        for line in failure.message.splitlines():
            say(("  " + line).rstrip())
    if failure.places:
        say()
        rows = [(bold(place.file if place.line is None else f"{place.file}:{place.line}"), dim(place.why))
                for place in failure.places]
        for line in term.table(rows, indent=""):
            say(line)
    notes = list(failure.advice)
    if failure.build_log:
        notes.append(f"The whole log of this build: {failure.build_log}")
    if failure.phase in ("evaluate", "build", "download"):
        try:
            waiting = update.pending(ctx.repo)
        except (YoError, OSError):
            waiting = None
        if waiting:
            notes.append(f"This is the first build since the update of {update.when(waiting)}. "
                         "If it built before, the update is the likely cause; take it back with: yo update --undo")
        if failure.phase == "evaluate" and not getattr(ctx.args, "trace", False):
            notes.append("The whole trace: yo build --trace")
    if len(failure.log.splitlines()) > len(failure.message.splitlines()) + 3:
        try:
            log = cache_dir() / "last-failure.log"
            log.parent.mkdir(parents=True, exist_ok=True)
            log.write_text(failure.log + "\n")
            notes.append(f"Everything that was printed: {log}")
        except OSError:
            pass
    if notes:
        say()
        for note in notes:
            say(dim(note))


def build_and_compare(ctx: Context) -> tuple[str, list[system.Change]]:
    repo, ref = ctx.repo, ctx.profile
    print(f"Building {bold(ref.name)}...", flush=True)
    built = system.build(repo, ref, on_line=print_progress, show_trace=getattr(ctx.args, "trace", False))
    current = system.current_system()
    changes = system.closure_diff(current, built) if current else []
    return built, changes


def cmd_build(ctx: Context):
    built, changes = build_and_compare(ctx)
    if built == system.current_system():
        print(good("The running system is already this configuration."))
        ctx.repo.record_applied(ctx.profile, built)
        return
    summarise_changes(changes, None if getattr(ctx.args, "all", False) else 40)
    term.note(f"Built {built}")
    term.note("Apply with: yo switch")


def run_updates(ctx: Context, names: list[str]) -> list[str]:
    repo = ctx.repo
    chosen = update.select(repo, names)
    print("Updating " + (", ".join(names) if names else "all flake inputs and pinned packages") + "...")
    changes = update.update(repo, chosen, everything=not names)
    repo.reload()
    if changes:
        for change in changes:
            print(f"  {change}")
    else:
        print("  Everything was already up to date.")
    return changes


def cmd_switch(ctx: Context):
    repo, ref = ctx.repo, ctx.profile
    action = "boot" if ctx.args.boot else "test" if ctx.args.test else "switch"
    if ctx.args.update:
        run_updates(ctx, [])
    built, changes = build_and_compare(ctx)
    if built == system.current_system():
        print(good("The running system is already this configuration."))
        repo.record_applied(ref, built)
        repo.remember_profile(ref)
        return
    summarise_changes(changes)
    verb = {"switch": "Switch to", "boot": "Boot into", "test": "Try"}[action]
    if not ctx.args.yes and not term.confirm(f"{verb} this system?"):
        term.note(f"Nothing changed. The build is kept at {built}")
        return 1
    system.activate(built, action, on_line=lambda line: print(dim("  " + line)))
    repo.remember_profile(ref)
    if action == "switch":
        repo.record_applied(ref, built)
        print(good(f"Switched to {ref.name}."))
    elif action == "boot":
        print(good(f"{ref.name} will be used from the next boot."))
    else:
        print(good(f"Trying {ref.name}; it lasts until the next reboot."))


def cmd_hop(ctx: Context):
    repo = ctx.repo
    if not ctx.args.target:
        return list_profiles(ctx)
    ref = repo.resolve_profile(ctx.args.target)
    repo.remember_profile(ref)
    ctx._profile = ref
    print(f"This machine now uses the profile {bold(ref.name)}.")
    if ctx.args.no_switch:
        return
    return cmd_switch(ctx)


def cmd_update(ctx: Context):
    repo = ctx.repo
    if ctx.args.undo:
        if ctx.args.names or ctx.args.check:
            raise YoError("--undo takes back the whole of the latest update, so it goes without names or --check")
        record = update.last_update(repo)
        restored = update.undo(repo)
        repo.reload()
        print(good(f"The update of {update.when(record)} is taken back. As they were before it:"))
        for name in restored:
            print(f"  {name}")
        if repo.in_sync() is True:
            term.note("The configuration matches the running system again.")
        else:
            term.note("Apply with: yo switch")
        return
    if ctx.args.check:
        chosen = update.select(repo, ctx.args.names)
        rows = []
        outdated = 0
        from concurrent.futures import ThreadPoolExecutor
        with ThreadPoolExecutor(max_workers=8) as pool:
            statuses = list(pool.map(lambda target: update.check(repo, target), chosen))
        for target, status in zip(chosen, statuses):
            if status.outdated:
                outdated += 1
                verdict = warn(f"update available: {status.latest}")
            elif status.outdated is False:
                verdict = good("up to date")
            else:
                verdict = dim(status.note or "unknown")
            owner = dim(f"{target.owner}: ") if target.owner and target.owner != target.name else ""
            rows.append((owner + bold(target.name), status.current, verdict))
        print("\n".join(term.table(rows, indent="")))
        if outdated:
            term.note(f"{outdated} can be updated: yo update" + ("" if not ctx.args.names else " <name>"))
        return
    changes = run_updates(ctx, ctx.args.names)
    if changes:
        term.note("Apply with: yo switch")


def cmd_upgrade(ctx: Context):
    ctx.args.update = True
    return cmd_switch(ctx)


def cmd_rollback(ctx: Context):
    entries = system.generations()
    current = next((entry for entry in entries if entry.get("current")), None)
    previous = next((entry for entry in entries if current and entry["generation"] < current["generation"]), None)
    if not previous:
        raise YoError("There is no earlier generation to go back to")
    question = f"Go back from generation {current['generation']} to {previous['generation']} ({previous.get('date', '?')})?"
    if not ctx.args.yes and not term.confirm(question):
        return 1
    system.rollback(on_line=lambda line: print(dim("  " + line)))
    print(good(f"Back on generation {previous['generation']}."))


def cmd_generations(ctx: Context):
    rows = []
    for entry in system.generations()[: ctx.args.limit]:
        mark = good("●") if entry.get("current") else "○"
        rows.append((mark, str(entry["generation"]), entry.get("date", ""), entry.get("nixosVersion", ""),
                     dim("kernel " + entry.get("kernelVersion", "?"))))
    print("\n".join(term.table(rows, indent="")))


def cmd_gc(ctx: Context):
    older = None if ctx.args.all else ctx.args.older_than
    what = "every old generation" if ctx.args.all else f"generations older than {older}"
    if not ctx.args.yes and not term.confirm(f"Delete {what} and everything only they use?"):
        return 1
    system.collect_garbage(older, on_line=lambda line: print(dim("  " + line)) if "deleting" not in line else None)
    print(good("Done."))


def cmd_check(ctx: Context):
    repo = ctx.repo
    problems = 0
    for name, entry in sorted(repo.sets.items()):
        if entry["kind"] == "invalid":
            print(warn(f"{entry['file']}: neither data nor a module"))
            problems += 1
            continue
        for member in entry.get("sets", []):
            if member not in repo.sets:
                print(warn(f"{entry['file']}: switches on the unknown set {member}"))
                problems += 1
        for package, variants in entry.get("packages", {}).items():
            defined = {variant["name"] for variant in repo.packages.get(package, {}).get("variants", [])}
            for variant in variants:
                if variant != "basic" and variant not in defined:
                    print(warn(f"{entry['file']}: {package} has no variant {variant}"))
                    problems += 1
    try:
        update.targets(repo)
    except YoError as error:
        print(warn(str(error)))
        problems += 1
    refs = repo.profiles() if ctx.args.all else [ctx.profile]
    for ref in refs:
        print(f"Evaluating {bold(ref.name)}...")
        result = subprocess.run(
            ["nix", "eval", "--raw", repo.flake_ref(ref, "config.system.build.toplevel.drvPath")],
            capture_output=True, text=True)
        if result.returncode != 0:
            problems += 1
            lines = [line for line in result.stderr.strip().splitlines()
                     if not line.startswith(("unpacking ", "copying "))]
            print(term.bad("  does not evaluate:"))
            print("\n".join("    " + line for line in lines[-25:]))
        else:
            print(good("  evaluates"))
    if problems:
        raise YoError(f"{problems} problem{'s' if problems != 1 else ''} found")
    print(good("No problems found."))


def cache_repair_command() -> str:
    import grp
    import pwd
    user = pwd.getpwuid(os.getuid()).pw_name
    group = grp.getgrgid(os.getgid()).gr_name
    return f"sudo chown -R {user}:{group} {nix_cache_dir()}"


def check_cache(offer: bool = True) -> bool:
    """Say so when Nix's cache is not this user's to write, and offer to repair it.

    Returns whether the cache is usable now.
    """
    if not foreign_cache_entries():
        return True
    print(warn("Nix's cache needs repair."), file=sys.stderr)
    print(CACHE_PROBLEM.format(directory=nix_cache_dir()), file=sys.stderr)
    if offer and sys.stdin.isatty() and term.confirm("Give it back to you now? (uses sudo)"):
        system.repair_cache()
        if not foreign_cache_entries():
            print(good("Repaired."))
            return True
        print(warn("Some of it still belongs to someone else."), file=sys.stderr)
    print(dim(f"Repair it with: yo doctor --fix   (or: {cache_repair_command()})"), file=sys.stderr)
    return False


def cmd_doctor(ctx: Context):
    """Look for what would keep yo from working, and repair what can be repaired."""
    problems = 0
    rows = []

    def report(what: str, fine: bool, detail: str):
        nonlocal problems
        problems += not fine
        rows.append((good("ok") if fine else term.bad("problem"), bold(what), detail))

    repo = ctx.repo
    report("Configuration", True, str(repo.root))
    try:
        ref = ctx.profile
        report("Profile", True, ref.name)
    except YoError as error:
        ref = None
        report("Profile", False, str(error).splitlines()[0])

    features = subprocess.run(["nix", "config", "show", "experimental-features"], capture_output=True, text=True)
    enabled = features.stdout.split()
    flakes = features.returncode == 0 and "flakes" in enabled and "nix-command" in enabled
    report("Nix", flakes, "flakes are enabled" if flakes
           else "needs: experimental-features = nix-command flakes")

    foreign = foreign_cache_entries()
    if foreign and ctx.args.fix:
        system.repair_cache()
        foreign = foreign_cache_entries()
    report("Nix's cache", not foreign,
           f"{nix_cache_dir()} is yours" if not foreign
           else f"parts of {nix_cache_dir()} belong to root; repair with: yo doctor --fix")

    if ref is not None and not foreign:
        try:
            repo.evaluated_state(ref)
            report("Evaluation", True, f"{ref.name} evaluates")
        except YoError as error:
            report("Evaluation", False, str(error).strip().splitlines()[-1].strip())

    running = (repo.running_state() or {}).get("profile", {}).get("name")
    report("Running system", True, f"built from {running}" if running else "not switched with yo yet")

    for line in term.table(rows, indent=""):
        print(line)
    if foreign:
        print()
        print(CACHE_PROBLEM.format(directory=nix_cache_dir()))
        term.note(f"yo doctor --fix runs: {cache_repair_command()}")
    return 1 if problems else 0


def cmd_repl(ctx: Context):
    os.execvp("nix", ["nix", "repl", f"path:{ctx.repo.root}"])


def cmd_gui(ctx: Context):
    try:
        from .gui import main as gui_main
    except ImportError as error:
        raise YoError(
            "The graphical interface needs GTK 4 and libadwaita, which this Python cannot find "
            f"({error}). Use the installed yo (it brings them along), or: nix run path:{ctx.repo.root}#yo -- gui")
    return gui_main(ctx.args.root, ctx.args.profile, ctx.args.page)


# -------------------------------------------------------------------- parser


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="yo",
        description="Manage this NixOS configuration: its profiles, sets and packages.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""\
everyday:
  yo                      where things stand
  yo add <package>        select a package for this machine
  yo enable <set>         switch a set on
  yo switch               build the configuration and switch to it
  yo update               refresh every pinned version
  yo gui                  the same, in a window
""")
    parser.add_argument("--version", action="version", version=f"yo {__version__}")
    parser.add_argument("-C", "--root", metavar="DIR", help="the configuration to work on (default: found automatically)")
    parser.add_argument("-p", "--profile", metavar="USER-MACHINE", help="the profile to work on (default: this machine's)")
    sub = parser.add_subparsers(dest="command", metavar="command")

    def command(name, handler, help_text, aliases=()):
        child = sub.add_parser(name, help=help_text, description=help_text, aliases=list(aliases))
        child.set_defaults(handler=handler)
        # Accepted after the command as well, because that is where one types it.
        child.add_argument("-p", "--profile", default=argparse.SUPPRESS, help=argparse.SUPPRESS)
        return child

    def shared(child):
        child.add_argument("--shared", action="store_true",
                           help="change the profile shared by all your machines instead of this machine's")

    command("status", cmd_status, "where things stand")

    child = command("list", cmd_list, "the sets and packages of the profile", aliases=["ls"])
    child.add_argument("what", nargs="?", choices=["sets", "packages", "profiles"], help="what to list (default: sets and packages)")
    child.add_argument("--on", action="store_true", help="only sets that are switched on")

    child = command("show", cmd_show, "details of a set, a package or an option")
    child.add_argument("name")

    child = command("why", cmd_why, "what selects a package")
    child.add_argument("package")

    child = command("options", cmd_options, "the options of the sets, with their values")
    child.add_argument("prefix", nargs="?", help="only options under this name, e.g. desktop")

    child = command("search", cmd_search, "find packages and sets, here and in nixpkgs")
    child.add_argument("term")
    child.add_argument("--local", action="store_true", help="do not search nixpkgs")

    child = command("enable", cmd_enable, "switch sets on")
    child.add_argument("sets", nargs="+", metavar="set")
    shared(child)
    child = command("disable", cmd_disable, "switch sets off")
    child.add_argument("sets", nargs="+", metavar="set")
    shared(child)

    child = command("option", cmd_option, "show an option, or give it a value")
    child.add_argument("name")
    child.add_argument("value", nargs="*", default=None, help="the new value; several words make a list")
    child.add_argument("--unset", action="store_true", help="remove the profile's own value")
    shared(child)

    child = command("add", cmd_add, "select packages")
    child.add_argument("packages", nargs="+", metavar="package")
    child.add_argument("--to", metavar="SET", help="add to this set instead of the profile")
    child.add_argument("-v", "--variant", action="append", help="the variant to select (default: basic)")
    child.add_argument("--no-verify", action="store_true", help="do not check that the package exists")
    shared(child)

    child = command("rm", cmd_rm, "stop selecting packages", aliases=["remove"])
    child.add_argument("packages", nargs="+", metavar="package")
    child.add_argument("--from", dest="from_set", metavar="SET", help="remove from this set instead of the profile")
    child.add_argument("-v", "--variant", action="append", help="only this variant")
    shared(child)

    child = command("exclude", cmd_exclude, "keep packages off this profile although a set selects them")
    child.add_argument("packages", nargs="+", metavar="package")
    child.add_argument("-v", "--variant", action="append", help="the variant to exclude (default: basic)")
    shared(child)
    child = command("include", cmd_include, "undo an exclude")
    child.add_argument("packages", nargs="+", metavar="package")
    shared(child)

    child = command("new", cmd_new, "create a set, a package directory or a profile")
    kinds = child.add_subparsers(dest="kind", metavar="what", required=True)
    new_set = kinds.add_parser("set", help="a new set of packages")
    new_set.add_argument("name", metavar="category/name")
    new_set.add_argument("packages", nargs="*", metavar="package")
    new_set.add_argument("-d", "--description", help="what the set is, in a few words")
    new_set.add_argument("--no-verify", action="store_true", help="do not check that the packages exist")
    new_package = kinds.add_parser("package", help="a directory under src/ for a package that needs configuring")
    new_package.add_argument("name")
    new_package.add_argument("variant", nargs="?", default="basic")
    new_package.add_argument("--dir", action="store_true", help="make the variant a directory, to keep files next to it")
    new_prof = kinds.add_parser("profile", help="a profile for a user and a machine")
    new_prof.add_argument("user", nargs="?")
    new_prof.add_argument("machine", nargs="?")
    new_prof.add_argument("--like", metavar="USER", help="start from this user's shared profile")

    child = command("init", cmd_init, "set this machine up: create its profile")
    child.add_argument("user", nargs="?")
    child.add_argument("machine", nargs="?")
    child.add_argument("--like", metavar="USER", help="start from this user's shared profile")

    child = command("edit", cmd_edit, "open the file of a set, a package or the profile")
    child.add_argument("name", help="a set, a package, or one of: profile, shared, pinned")

    child = command("build", cmd_build, "build the configuration and show what would change", aliases=["diff"])
    child.add_argument("--all", action="store_true", help="list every change")
    child.add_argument("--trace", action="store_true", help="show a trace when evaluation fails")

    child = command("switch", cmd_switch, "build the configuration and switch to it", aliases=["rebuild"])
    child.add_argument("-u", "--update", action="store_true", help="refresh pinned versions first")
    child.add_argument("-y", "--yes", action="store_true", help="do not ask before switching")
    child.add_argument("--boot", action="store_true", help="use it from the next boot instead of now")
    child.add_argument("--test", action="store_true", help="try it now without making it the boot default")
    child.add_argument("--trace", action="store_true", help="show a trace when evaluation fails")

    child = command("update", cmd_update, "refresh pinned versions (flake inputs and package pins)")
    child.add_argument("names", nargs="*", metavar="name", help="packages or flake inputs (default: everything)")
    child.add_argument("--check", action="store_true", help="only report what could be updated")
    child.add_argument("--undo", action="store_true",
                       help="take the latest update back: flake.lock and the pins as they were before it")

    child = command("upgrade", cmd_upgrade, "update everything, then switch")
    child.add_argument("-y", "--yes", action="store_true", help="do not ask before switching")
    child.set_defaults(boot=False, test=False, trace=False)

    child = command("rollback", cmd_rollback, "go back to the previous generation")
    child.add_argument("-y", "--yes", action="store_true", help="do not ask")

    child = command("generations", cmd_generations, "the generations of this system")
    child.add_argument("-n", "--limit", type=int, default=15, help="how many to show (default: 15)")

    child = command("gc", cmd_gc, "delete old generations and unused store paths")
    child.add_argument("--older-than", default="30d", metavar="AGE", help="keep generations newer than this (default: 30d)")
    child.add_argument("--all", action="store_true", help="delete every old generation")
    child.add_argument("-y", "--yes", action="store_true", help="do not ask")

    child = command("check", cmd_check, "check that the configuration is sound")
    child.add_argument("--all", action="store_true", help="evaluate every profile, not only this machine's")

    child = command("hop", cmd_hop, "make another profile this machine's, and switch to it")
    child.add_argument("target", nargs="?", metavar="profile")
    child.add_argument("--no-switch", action="store_true", help="only remember the choice")
    child.set_defaults(update=False, yes=False, boot=False, test=False, trace=False)

    child = command("doctor", cmd_doctor, "check that yo has what it needs, and repair what it can")
    child.add_argument("--fix", action="store_true", help="repair what can be repaired (may use sudo)")

    command("repl", cmd_repl, "a Nix REPL with the configuration loaded")
    child = command("gui", cmd_gui, "open the graphical interface")
    child.add_argument("page", nargs="?", choices=["overview", "sets", "packages", "updates"],
                       help="the page to open on")
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    if "NO_COLOR" in os.environ:
        term.enabled = False
    ctx = Context(args)
    handler = getattr(args, "handler", cmd_status)
    try:
        if handler not in (cmd_doctor, cmd_gui):
            ctx.cache_usable = check_cache()
        return handler(ctx) or 0
    except Failed as error:
        report_failure(ctx, error.failure)
        return 1
    except (YoError, EditError, NotData) as error:
        term.error(str(error))
        return 1
    except KeyboardInterrupt:
        print()
        return 130
    except BrokenPipeError:
        return 0
