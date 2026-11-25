"""Changes to the configuration: switching sets, choosing packages, scaffolding.

Every function here edits files in the working tree and nothing else; the
system only changes when the result is built and switched to.
"""

from __future__ import annotations

import copy
import difflib
import re
import subprocess
from pathlib import Path

from . import nixdata
from .nixdata import AttrSet, Scalar
from .repo import ProfileRef, Repo, YoError

NAME = re.compile(r"[A-Za-z0-9_][A-Za-z0-9_.+-]*")


def suggest(name: str, known) -> str:
    close = difflib.get_close_matches(name, list(known), n=3, cutoff=0.6)
    return f" Did you mean {', '.join(close)}?" if close else ""


def set_name(repo: Repo, name: str) -> str:
    """Accept dev.python, dev/python and modules.dev.python alike."""
    normal = name.strip().replace("/", ".")
    if normal.startswith("modules."):
        normal = normal[len("modules."):]
    if normal.endswith(".enable"):
        normal = normal[:-len(".enable")]
    if normal not in repo.sets:
        raise YoError(f"There is no set {name!r}.{suggest(normal, repo.sets)}")
    return normal


def _ensure(path: Path, header: str = ""):
    if not path.exists():
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(header + "{\n}\n")


def _lookup(tree: dict, path: list[str]):
    for part in path:
        if not isinstance(tree, dict) or part not in tree:
            return None
        tree = tree[part]
    return tree


def _assign(tree: dict, path: list[str], value):
    for part in path[:-1]:
        tree = tree.setdefault(part, {})
    tree[path[-1]] = value


def _drop(tree: dict, path: list[str]):
    """Remove `path` and the attribute sets this leaves empty."""
    if not path or not isinstance(tree, dict) or path[0] not in tree:
        return
    if len(path) == 1:
        del tree[path[0]]
        return
    _drop(tree[path[0]], path[1:])
    if tree[path[0]] == {}:
        del tree[path[0]]


# ------------------------------------------------------------------ options


def write_option(repo: Repo, ref: ProfileRef, option: str, value, shared: bool = False) -> Path:
    """Define modules.<option> in the profile."""
    file = repo.profile_file(ref, shared)
    _ensure(file)
    path = ["modules", *option.split(".")]

    def expected(before):
        after = copy.deepcopy(before)
        _assign(after, path, value)
        return after

    nixdata.edit(file, lambda document: document.set(path, value), expected)
    repo.reload()
    return file


def clear_option(repo: Repo, ref: ProfileRef, option: str, shared: bool = False) -> Path | None:
    """Remove the profile's own definition of modules.<option>, if it has one."""
    file = repo.profile_file(ref, shared)
    if not file.exists():
        return None
    path = ["modules", *option.split(".")]
    if _lookup(nixdata.evaluate(path=file), path) is None:
        return None

    def expected(before):
        after = copy.deepcopy(before)
        _drop(after, path)
        return after

    nixdata.edit(file, lambda document: document.delete(path), expected)
    repo.reload()
    return file


def _explicit(repo: Repo, ref: ProfileRef, option: str, shared: bool):
    data = (repo.profile_entry(ref, shared).get("data") or {}).get("value") or {}
    return _lookup(data.get("modules", {}), option.split("."))


def _inherited_enable(repo: Repo, ref: ProfileRef, name: str, shared: bool, state: dict | None) -> tuple[bool, str]:
    """Whether a set is on if the profile being edited says nothing about it."""
    if not shared:
        value = _explicit(repo, ref, name + ".enable", shared=True)
        if isinstance(value, bool):
            return value, "your shared profile"
    entry = repo.sets[name]
    if entry.get("default"):
        return True, "its default"
    if state:
        for option in state.get("options", []):
            if option["name"] == name + ".enable" and option.get("default") is True:
                return True, "its default"
    # Switched on by another data set that is itself on?
    from .repo import static_selection
    selection = static_selection(repo, ref)
    for other, origin in selection["sets"].items():
        if other != name and name in repo.sets.get(other, {}).get("sets", []):
            return True, f"the set {other}"
    return False, ""


def switch_set(repo: Repo, ref: ProfileRef, name: str, on: bool, shared: bool = False,
               state: dict | None = None) -> str:
    """Switch a set on or off in the profile. Returns what was done, in words."""
    name = set_name(repo, name)
    option = name + ".enable"
    inherited, origin = _inherited_enable(repo, ref, name, shared, state)
    where = "your shared profile" if shared else f"the {ref.machine} profile"
    current = _explicit(repo, ref, option, shared)

    if on == inherited:
        # Saying nothing is enough; drop a definition that says otherwise.
        if current is not None and current != on:
            clear_option(repo, ref, option, shared)
            return (f"{name} switched {'on' if on else 'off'} in {where}"
                    + (f" (it comes from {origin})" if origin else ""))
        if current is None:
            return f"{name} is already {'on' if on else 'off'}" + (f" through {origin}" if origin else "")
    if current == on:
        return f"{name} is already {'on' if on else 'off'} ({where})"
    write_option(repo, ref, option, on, shared)
    return f"{name} switched {'on' if on else 'off'} in {where}"


def coerce(option: dict | None, text: str):
    """Turn what was typed for an option into its value."""
    kind = option.get("kind") if option else None
    lowered = text.strip().lower()
    if kind == "bool" or (kind is None and lowered in {"true", "false"}):
        if lowered in {"true", "on", "yes", "1"}:
            return True
        if lowered in {"false", "off", "no", "0"}:
            return False
        raise YoError(f"{option['name'] if option else 'the option'} takes true or false, not {text!r}")
    if kind == "enum":
        if text not in option.get("choices", []):
            raise YoError(f"{option['name']} must be one of: {', '.join(map(str, option['choices']))}")
        return text
    if kind in {"enums", "strings"}:
        values = [part for part in re.split(r"[,\s]+", text.strip()) if part]
        if kind == "enums":
            wrong = [value for value in values if value not in option.get("choices", [])]
            if wrong:
                raise YoError(
                    f"{option['name']} only takes: {', '.join(map(str, option['choices']))} (not {', '.join(wrong)})")
        return values
    if kind == "int" or (kind is None and re.fullmatch(r"-?[0-9]+", lowered)):
        try:
            return int(text)
        except ValueError:
            raise YoError(f"{option['name'] if option else 'the option'} takes a whole number, not {text!r}")
    return text


# ----------------------------------------------------------------- packages


def _item(name: str, variants: list[str]):
    return name if variants == ["basic"] else {name: variants}


def _names(node, source: str) -> list[str] | None:
    """The package names a list entry speaks for."""
    if isinstance(node, Scalar) and node.kind == "string":
        import json
        try:
            return [json.loads(source)]
        except ValueError:
            return None
    if isinstance(node, AttrSet):
        return [binding.path[0] for binding in node.bindings if len(binding.path) == 1]
    return None


def _change_list(file: Path, key: str, name: str, variants: list[str] | None):
    """Make the `key` list of a data file select exactly `variants` of `name`."""

    def owns(node, source):
        names = _names(node, source)
        if names is None or name not in names:
            return False
        if len(names) > 1:
            raise nixdata.EditError(
                f"{file}: {name} shares a list entry with other packages; please edit the file by hand")
        return True

    def remaining(value) -> list:
        kept = [entry for entry in value.get(key, [])
                if entry != name and not (isinstance(entry, dict) and name in entry)]
        return kept + ([_item(name, variants)] if variants else [])

    # An exclusion list that ends up empty says nothing, so it goes.
    drop_empty = key == "exclude"
    before_value = evaluate_or_empty(file)

    def change(document):
        document.list_remove([key], owns)
        if variants:
            document.list_add([key], _item(name, variants))
        elif drop_empty and not remaining(before_value):
            document.delete([key])

    def expected(before):
        after = copy.deepcopy(before)
        kept = remaining(before)
        if kept or (key in after and not drop_empty):
            after[key] = kept
        else:
            after.pop(key, None)
        return after

    nixdata.edit(file, change, expected)


def evaluate_or_empty(file: Path) -> dict:
    return nixdata.evaluate(path=file) if file.exists() else {}


def _selection_of(repo: Repo, file: Path, key: str) -> dict:
    """The { package: [variants] } a data file's list currently stands for."""
    value = nixdata.evaluate(path=file) if file.exists() else {}
    selection: dict[str, list[str]] = {}
    for entry in value.get(key, []):
        if isinstance(entry, str):
            selection.setdefault(entry, []).append("basic")
        else:
            for package, variants in entry.items():
                selection.setdefault(package, []).extend(variants)
    return selection


def check_package(repo: Repo, name: str, variants: list[str]):
    """Fail unless every variant of `name` can be resolved."""
    if not NAME.fullmatch(name):
        raise YoError(f"{name!r} is not a package name")
    known = repo.packages.get(name)
    defined = {variant["name"] for variant in known["variants"]} if known else set()
    for variant in variants:
        if variant in defined:
            continue
        if variant != "basic":
            hint = f" It has: {', '.join(sorted(defined))}." if defined else ""
            raise YoError(f"The package {name} has no variant {variant!r} under src/.{hint}")
        if not in_nixpkgs(name):
            raise YoError(
                f"{name} is neither a package under src/ nor an attribute of nixpkgs."
                + suggest(name, repo.packages) + f" Try: yo search {name}")


def in_nixpkgs(name: str) -> bool:
    result = subprocess.run(
        ["nix", "eval", "--raw", f"nixpkgs#{name}.name"],
        capture_output=True, text=True,
    )
    return result.returncode == 0


def target_file(repo: Repo, ref: ProfileRef, into: str | None, shared: bool) -> tuple[Path, str]:
    """Where a package selection is written: (file, description)."""
    if into:
        name = set_name(repo, into)
        if repo.sets[name]["kind"] != "data":
            raise YoError(
                f"The set {name} is written as a module ({repo.sets[name]['file']}), "
                "so yo cannot edit its packages. Edit the file, or pick another set.")
        return repo.set_file(name), f"the set {name}"
    file = repo.profile_file(ref, shared)
    return file, "your shared profile" if shared else f"the {ref.machine} profile"


def add_package(repo: Repo, ref: ProfileRef, name: str, variants: list[str] | None = None,
                into: str | None = None, shared: bool = False, verify: bool = True) -> str:
    variants = variants or ["basic"]
    file, where = target_file(repo, ref, into, shared)
    if verify:
        check_package(repo, name, variants)
    _ensure(file)
    current = _selection_of(repo, file, "packages").get(name, [])
    wanted = current + [variant for variant in variants if variant not in current]
    if wanted == current:
        return f"{name} is already in {where}"
    _change_list(file, "packages", name, wanted)
    repo.reload()
    return f"{name} added to {where}"


def remove_package(repo: Repo, ref: ProfileRef, name: str, variants: list[str] | None = None,
                   into: str | None = None, shared: bool = False) -> str | None:
    """Take a package out of a profile or set. None when it was not there."""
    file, where = target_file(repo, ref, into, shared)
    current = _selection_of(repo, file, "packages").get(name)
    if not current:
        return None
    wanted = [variant for variant in current if variant not in variants] if variants else []
    if wanted == current:
        return None
    _change_list(file, "packages", name, wanted)
    repo.reload()
    return f"{name} removed from {where}"


def exclude_package(repo: Repo, ref: ProfileRef, name: str, variants: list[str] | None = None,
                    shared: bool = False) -> str:
    """Keep a package off this profile even though a set selects it."""
    file = repo.profile_file(ref, shared)
    _ensure(file)
    variants = variants or ["basic"]
    current = _selection_of(repo, file, "exclude").get(name, [])
    wanted = current + [variant for variant in variants if variant not in current]
    where = "your shared profile" if shared else f"the {ref.machine} profile"
    if wanted == current:
        return f"{name} is already excluded in {where}"
    _change_list(file, "exclude", name, wanted)
    repo.reload()
    return f"{name} excluded in {where}"


def include_package(repo: Repo, ref: ProfileRef, name: str, shared: bool = False) -> str | None:
    """Undo an exclusion."""
    file = repo.profile_file(ref, shared)
    if not _selection_of(repo, file, "exclude").get(name):
        return None
    _change_list(file, "exclude", name, None)
    repo.reload()
    return f"{name} is no longer excluded"


# --------------------------------------------------------------- scaffolding


def new_set(repo: Repo, name: str, description: str, packages: list[str]) -> Path:
    normal = name.strip().replace("/", ".")
    parts = normal.split(".")
    if len(parts) < 2 or not all(NAME.fullmatch(part) for part in parts):
        raise YoError("Name a set as <category>/<name>, for example dev/zig")
    if normal in repo.sets:
        raise YoError(f"The set {normal} already exists ({repo.sets[normal]['file']})")
    file = repo.root / "modules" / Path(*parts[:-1]) / f"{parts[-1]}.nix"
    file.parent.mkdir(parents=True, exist_ok=True)
    lines = ["{", f"  description = {nixdata.render(description or normal)};", "  packages = ["]
    lines += [f"    {nixdata.render(package)}" for package in packages]
    lines += ["  ];", "}"]
    file.write_text("\n".join(lines) + "\n")
    repo.reload()
    return file


PACKAGE_TEMPLATE = """\
{{ config, lib, pkgs, inputs, ... }}:

{{
  {body}
}}
"""


def new_package(repo: Repo, name: str, variant: str = "basic", directory: bool = False) -> Path:
    """Give a package a file of its own under src/, to hold its configuration."""
    if not NAME.fullmatch(name) or not NAME.fullmatch(variant):
        raise YoError("Package and variant names may only contain letters, digits, and . _ + -")
    known = repo.packages.get(name)
    if known and variant in {entry["name"] for entry in known["variants"]}:
        raise YoError(f"src/{name} already has a {variant} variant")
    base = repo.root / "src" / name
    file = base / variant / "default.nix" if directory else base / f"{variant}.nix"
    file.parent.mkdir(parents=True, exist_ok=True)
    attribute = ".".join(nixdata.attr(part) for part in name.split("."))
    body = (f"home.packages = [ pkgs.{attribute} ];" if variant == "basic"
            else f"# What the {variant} variant of {name} adds goes here.")
    file.write_text(PACKAGE_TEMPLATE.format(body=body))
    repo.reload()
    return file


COMMON_TEMPLATE = """\
{{ config, pkgs, lib, inputs, ... }}:

{{
  user = {{
    name = {user};
    hostName = {host};
    fullName = {full_name};
    email = {email};
  }};

  dotfiles.dir = {root};
}}
"""

SHARED_PROFILE = """\
# What every machine of this user gets. A machine's own profile.nix adds to
# this or overrides single values. Change it with yo, or by hand.
{
  modules = {
    shell = {
      enable = true;
      env = [ "bash" ];
      defaultShell = "bash";
      loginShell = "bash";
      tools.enable = true;
      integration.enable = true;
    };

    desktop = {
      wayland = {
        enable = true;
        minimum = true;
      };
      gtk = {
        enable = true;
        gnome.enable = true;
      };
      display = {
        enable = true;
        package = "gdm";
      };
    };

    io = {
      audio.enable = true;
      bluetooth.enable = true;
    };

    network = {
      nm.enable = true;
      ssh.enable = true;
    };

    nix = {
      gc.enable = true;
      channel = "unstable";
    };

    boot = {
      kernel = "latest";
    };

    locale = {
      enable = true;
      defaultFonts = true;
    };
  };
}
"""

MACHINE_PROFILE = """\
# What this machine adds to, or changes in, the shared profile one directory up.
{
}
"""

PINNED_TEMPLATE = """\
{{ config, pkgs, lib, inputs, ... }}:

# Settings pinned to this machine that are not a matter of sets and packages.
{{
  system.stateVersion = {state_version};
}}
"""

HARDWARE_PLACEHOLDER = """\
# Placeholder. Replace with the output of:
#   nixos-generate-config --show-hardware-config
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];
}
"""


def nixos_release() -> str:
    try:
        version = subprocess.run(["nixos-version"], capture_output=True, text=True).stdout
        match = re.match(r"([0-9]+\.[0-9]+)", version)
        if match:
            return match.group(1)
    except OSError:
        pass
    return "25.11"


def hardware_configuration() -> tuple[str, bool]:
    """This machine's hardware configuration, and whether it was detected."""
    try:
        result = subprocess.run(
            ["nixos-generate-config", "--show-hardware-config"], capture_output=True, text=True)
        if result.returncode == 0 and "fileSystems" in result.stdout:
            return result.stdout, True
    except OSError:
        pass
    return HARDWARE_PLACEHOLDER, False


def new_profile(repo: Repo, user: str, machine: str, *, host: str | None = None,
                full_name: str = "", email: str = "", copy_from: str | None = None) -> list[str]:
    """Create profiles/<user>/<machine>, and the user's directory if it is new."""
    for value, what in ((user, "user"), (machine, "machine")):
        if not re.fullmatch(r"[a-z_][a-z0-9_-]*", value):
            raise YoError(f"The {what} name {value!r} should be lower-case letters, digits, - or _")
    notes = []
    user_dir = repo.root / "profiles" / user
    machine_dir = user_dir / machine
    if machine_dir.exists():
        raise YoError(f"The profile {user}-{machine} already exists")

    if not user_dir.exists():
        user_dir.mkdir(parents=True)
        (user_dir / "common.nix").write_text(COMMON_TEMPLATE.format(
            user=nixdata.render(user), host=nixdata.render(host or machine),
            full_name=nixdata.render(full_name), email=nixdata.render(email),
            root=nixdata.render(str(repo.root))))
        notes.append(f"profiles/{user}/common.nix (who you are)")
        shared = SHARED_PROFILE
        if copy_from:
            source = repo.root / "profiles" / copy_from / "profile.nix"
            if not source.is_file():
                raise YoError(f"There is no profiles/{copy_from}/profile.nix to copy from")
            shared = source.read_text()
        (user_dir / "profile.nix").write_text(shared)
        notes.append(f"profiles/{user}/profile.nix (the sets every machine of yours gets)")

    machine_dir.mkdir()
    (machine_dir / "profile.nix").write_text(MACHINE_PROFILE)
    notes.append(f"profiles/{user}/{machine}/profile.nix (what this machine adds)")
    (machine_dir / "pinned.nix").write_text(
        PINNED_TEMPLATE.format(state_version=nixdata.render(nixos_release())))
    notes.append(f"profiles/{user}/{machine}/pinned.nix (settings pinned to this machine)")
    hardware, detected = hardware_configuration()
    (machine_dir / "hardware-configuration.nix").write_text(hardware)
    notes.append(
        f"profiles/{user}/{machine}/hardware-configuration.nix "
        + ("(detected from this machine)" if detected else "(a placeholder: replace it before building)"))
    repo.reload()
    return notes
