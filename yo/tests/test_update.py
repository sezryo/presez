"""An update can be taken back: what the files held before it is remembered."""

import tempfile
import time
import unittest
from pathlib import Path
from unittest import mock

from yo import update
from yo.repo import YoError
from yo.update import Target


class Configuration:
    """As much of a Repo as updating looks at."""

    def __init__(self, root: Path):
        self.root = root
        self.applied_at: float | None = None

    def applied(self) -> dict:
        return {} if self.applied_at is None else {"time": self.applied_at}


class Undo(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        base = Path(self.directory.name)
        self.root = base / "config"
        self.lock = self.root / "flake.lock"
        self.pin = self.root / "src/tool/release.json"
        self.pin.parent.mkdir(parents=True)
        self.lock.write_text("lock 1\n")
        self.pin.write_text("pin 1\n")
        self.repo = Configuration(self.root)
        self.tool = Target("tool", "pin", owner="tool", spec={"type": "github-release"}, directory=self.pin.parent)
        self.script = Target("script", "pin", owner="script", spec={"type": "command", "run": ["true"]},
                             directory=self.root / "src/script")
        self.script.directory.mkdir()
        self.versions = iter(range(2, 100))
        patches = [
            mock.patch.object(update, "state_dir", lambda: base / "state"),
            mock.patch.object(update, "update_inputs", self.new_lock),
            mock.patch.object(update, "update_release", self.new_pin),
        ]
        for patch in patches:
            patch.start()
            self.addCleanup(patch.stop)
        self.addCleanup(self.directory.cleanup)

    def new_lock(self, repo, names):
        version = next(self.versions)
        self.lock.write_text(f"lock {version}\n")
        return [f"nixpkgs: {version - 1} -> {version}"]

    def new_pin(self, target):
        version = next(self.versions)
        self.pin.write_text(f"pin {version}\n")
        return f"tool: {version - 1} -> {version}"

    def everything(self):
        return update.update(self.repo, [Target("nixpkgs", "input"), self.tool], everything=True)

    def test_taken_back(self):
        changes = self.everything()
        self.assertEqual((self.lock.read_text(), self.pin.read_text()), ("lock 2\n", "pin 3\n"))
        record = update.pending(self.repo)
        self.assertEqual(record["changes"], changes)
        self.assertEqual(update.undo(self.repo), ["flake.lock", "src/tool/release.json"])
        self.assertEqual((self.lock.read_text(), self.pin.read_text()), ("lock 1\n", "pin 1\n"))
        self.assertIsNone(update.last_update(self.repo))
        with self.assertRaises(YoError):
            update.undo(self.repo)

    def test_updates_never_applied_are_taken_back_together(self):
        self.everything()
        update.update(self.repo, [Target("nixpkgs", "input")], everything=False)
        self.assertEqual(self.lock.read_text(), "lock 4\n")
        self.assertEqual(len(update.pending(self.repo)["changes"]), 3)
        update.undo(self.repo)
        self.assertEqual((self.lock.read_text(), self.pin.read_text()), ("lock 1\n", "pin 1\n"))

    def test_an_applied_update_is_no_longer_the_suspect(self):
        self.everything()
        self.repo.applied_at = time.time()
        self.assertIsNone(update.pending(self.repo))
        self.assertIsNotNone(update.last_update(self.repo))       # but can still be taken back by hand
        # The next update starts from what was applied, not from before it.
        update.update(self.repo, [Target("nixpkgs", "input")], everything=False)
        self.assertEqual(len(update.pending(self.repo)["changes"]), 1)
        update.undo(self.repo)
        self.assertEqual((self.lock.read_text(), self.pin.read_text()), ("lock 2\n", "pin 3\n"))

    def test_files_changed_since_are_left_alone(self):
        self.everything()
        self.lock.write_text("edited by hand\n")
        self.assertIsNone(update.last_update(self.repo))
        with self.assertRaisesRegex(YoError, "changed again"):
            update.undo(self.repo)
        self.assertEqual(self.lock.read_text(), "edited by hand\n")

    def test_an_update_that_fails_halfway_can_be_taken_back(self):
        def broken(target):
            raise YoError("Could not ask GitHub")

        with mock.patch.object(update, "update_release", broken), self.assertRaises(YoError):
            self.everything()
        self.assertEqual(self.lock.read_text(), "lock 2\n")
        self.assertEqual(update.undo(self.repo), ["flake.lock"])
        self.assertEqual(self.lock.read_text(), "lock 1\n")

    def test_nothing_new_leaves_no_record(self):
        with mock.patch.object(update, "update_inputs", lambda repo, names: []), \
                mock.patch.object(update, "update_release", lambda target: None):
            self.assertEqual(self.everything(), [])
        self.assertIsNone(update.last_update(self.repo))

    def test_back_where_it_started_leaves_no_record(self):
        self.everything()

        def back(repo, names):
            self.lock.write_text("lock 1\n")
            self.pin.write_text("pin 1\n")
            return ["nixpkgs: 2 -> 1"]

        with mock.patch.object(update, "update_inputs", back):
            update.update(self.repo, [Target("nixpkgs", "input")], everything=False)
        self.assertIsNone(update.last_update(self.repo))

    def test_files_a_command_wrote_or_made(self):
        kept = self.script.directory / "version.txt"
        kept.write_text("1\n")
        made = self.script.directory / "extra.json"

        def run(target):
            kept.write_text("2\n")
            made.write_text("{}\n")
            return "script: updater ran"

        with mock.patch.object(update, "update_command", run):
            update.update(self.repo, [self.script], everything=False)
        self.assertEqual(update.undo(self.repo), ["src/script/extra.json", "src/script/version.txt"])
        self.assertEqual(kept.read_text(), "1\n")
        self.assertFalse(made.exists())
        self.assertEqual(self.lock.read_text(), "lock 1\n")


if __name__ == "__main__":
    unittest.main()
