"""What the interface shows and changes.

The model owns the repository and the profile being edited. Every change
goes through `apply_edit`, which remembers the files it touches so that the
last change can be undone, and afterwards re-evaluates the configuration so
that the views show what the tree would really build.
"""

from __future__ import annotations

import threading
from pathlib import Path

from .. import edit, system, update
from ..repo import ProfileRef, Repo, find_root, static_selection
from .util import run_async


class Model:
    def __init__(self, root: str | None, profile: str | None):
        self.repo = Repo(find_root(root))
        self.profile_name = profile
        self.ref: ProfileRef | None = None
        self.state: dict | None = None
        self.state_error: str | None = None
        self.shared = False            # write to the user's shared profile instead of the machine's
        self.listeners: list = []      # called after anything changed
        self._undo: list[tuple[Path, str | None]] = []
        self._lock = threading.Lock()  # edits and evaluations happen one at a time

    # ------------------------------------------------------------- loading

    def load(self):
        """Blocking: read the catalogue and evaluate the profile."""
        self.repo.reload()
        self.ref = self.repo.resolve_profile(self.profile_name)
        self._evaluate()

    def _evaluate(self):
        try:
            self.state = self.repo.evaluated_state(self.ref)
            self.state_error = None
        except Exception as error:
            self.state_error = str(error)
            if self.state is None:
                self.state, _ = self.repo.best_state(self.ref)

    def refresh(self, done=None):
        """Re-read everything in the background, then tell the views."""

        def work():
            with self._lock:
                self.repo.reload()
                self._evaluate()

        def finished(_):
            self.notify()
            if done:
                done()

        run_async(work, finished, lambda error: self.notify())

    def notify(self):
        for listener in list(self.listeners):
            listener()

    # ------------------------------------------------------------- reading

    @property
    def selection(self) -> dict:
        return static_selection(self.repo, self.ref)

    def options(self, prefix: str | None = None) -> list[dict]:
        found = (self.state or {}).get("options", [])
        if prefix is None:
            return found
        return [option for option in found if option["name"] == prefix or option["name"].startswith(prefix + ".")]

    def option(self, name: str) -> dict | None:
        for option in (self.state or {}).get("options", []):
            if option["name"] == name:
                return option
        return None

    def set_on(self, name: str) -> bool | None:
        option = self.option(name + ".enable")
        if option is not None and "value" in option:
            return bool(option["value"])
        if self.repo.sets[name]["kind"] == "data":
            return name in self.selection["sets"]
        if self.state is None:
            # Without an evaluation, a module's switch is known only where the profile sets it.
            return name in self.selection["sets"] or None
        return None

    def packages(self) -> dict:
        if self.state:
            return self.state.get("packages", {})
        return {name: sorted(variants) for name, variants in self.selection["packages"].items()}

    def origins(self, package: str) -> list[str]:
        found: list[str] = []
        for wheres in self.selection["packages"].get(package, {}).values():
            for where in wheres:
                if where not in found:
                    found.append(where)
        return found

    def in_sync(self) -> bool | None:
        return self.repo.in_sync()

    def where(self) -> str:
        return "all your machines" if self.shared else f"this machine ({self.ref.machine})"

    # ------------------------------------------------------------- editing

    def _files(self) -> list[Path]:
        files = [self.repo.profile_file(self.ref), self.repo.profile_file(self.ref, shared=True)]
        files += [self.repo.set_file(name) for name, entry in self.repo.sets.items() if entry["kind"] == "data"]
        return files

    def apply_edit(self, change, done=None, failed=None):
        """Run `change()` (which edits files) in the background.

        `done(message)` gets what `change` returned. On failure nothing is
        left half-written, because every edit is verified before it is saved.
        """
        def work():
            with self._lock:
                before = {path: (path.read_text() if path.exists() else None) for path in self._files()}
                try:
                    message = change()
                finally:
                    self.repo.reload()
                    touched = []
                    for path in set(before) | set(self._files()):
                        now = path.read_text() if path.exists() else None
                        if now != before.get(path):
                            touched.append((path, before.get(path)))
                    if touched:
                        self._undo = touched
                        self._evaluate()
                return message

        def finished(message):
            self.notify()
            if done:
                done(message)

        def broke(error):
            self.notify()
            if failed:
                failed(error)

        run_async(work, finished, broke)

    def can_undo(self) -> bool:
        return bool(self._undo)

    def undo(self, done=None):
        touched, self._undo = self._undo, []

        def work():
            with self._lock:
                for path, content in touched:
                    if content is None:
                        path.unlink(missing_ok=True)
                    else:
                        path.write_text(content)
                self.repo.reload()
                self._evaluate()

        run_async(work, lambda _: (self.notify(), done and done()), lambda error: self.notify())

    def switch_set(self, name: str, on: bool):
        return edit.switch_set(self.repo, self.ref, name, on, shared=self.shared, state=self.state)

    def write_option(self, name: str, value):
        option = self.option(name)
        if option is not None and option.get("default", object()) == value and not self._defined(name):
            return f"{name} is already {value}"
        edit.write_option(self.repo, self.ref, name, value, shared=self.shared)
        return f"{name} changed for {self.where()}"

    def _defined(self, name: str) -> bool:
        entry = self.repo.profile_entry(self.ref, self.shared)
        tree = ((entry.get("data") or {}).get("value") or {}).get("modules", {})
        for part in name.split("."):
            if not isinstance(tree, dict) or part not in tree:
                return False
            tree = tree[part]
        return True

    # -------------------------------------------------------------- system

    def generations(self) -> list[dict]:
        try:
            return system.generations()
        except Exception:
            return []

    def update_targets(self) -> list[update.Target]:
        return update.targets(self.repo)
