import unittest
from unittest import mock

from yo import edit, system, update
from yo.repo import ProfileRef, YoError, static_selection


class ClosureDiff(unittest.TestCase):
    def test_parse(self):
        text = "\n".join([
            "t3code: 0.1.10 → 0.1.11",
            "t3code-cli: 0.1.10 → 0.1.11, 9.4 MiB",
            "appstream: ∅ → 1.2.3, 476.3 KiB",
            "claude-desktop-no: ε → ∅, -776.2 MiB",
            "t3: 0.1.10, 0.1.10-fhsenv → 0.1.11, 0.1.11-fhsenv",
            "glibc: +12.0 KiB",
        ])
        changes = {change.name: change for change in system.parse_closure_diff(text)}
        self.assertEqual((changes["t3code"].old, changes["t3code"].new), ("0.1.10", "0.1.11"))
        self.assertEqual(changes["t3code-cli"].new, "0.1.11")
        self.assertEqual(changes["appstream"].kind, "added")
        self.assertEqual(changes["claude-desktop-no"].kind, "removed")
        self.assertEqual(changes["t3"].new, "0.1.11, 0.1.11-fhsenv")
        self.assertEqual(changes["glibc"].kind, "changed")


class Releases(unittest.TestCase):
    SPEC = {
        "repo": "owner/tool",
        "assets": {"x86_64-linux": {"app": ["Tool-{version}.AppImage", "Tool.AppImage"]}},
    }

    def release(self, **changes):
        asset = {
            "name": "Tool.AppImage", "state": "uploaded",
            "browser_download_url": "https://github.com/owner/tool/releases/download/v1.2.3/Tool.AppImage",
            "digest": "sha256:" + "ab" * 32,
        }
        asset.update(changes.pop("asset", {}))
        release = {"draft": False, "prerelease": False, "tag_name": "v1.2.3", "assets": [asset]}
        release.update(changes)
        return release

    def resolve(self, release):
        with mock.patch.object(update, "_latest_release", return_value=release):
            return update.resolve_release(self.SPEC)

    def test_resolves_pin(self):
        self.assertEqual(self.resolve(self.release()), {
            "version": "1.2.3",
            "systems": {"x86_64-linux": {"app": {
                "url": "https://github.com/owner/tool/releases/download/v1.2.3/Tool.AppImage",
                "sha256": "ab" * 32,
            }}},
        })

    def test_refuses_odd_tag(self):
        with self.assertRaises(YoError):
            self.resolve(self.release(tag_name="nightly"))

    def test_refuses_missing_asset(self):
        with self.assertRaises(YoError):
            self.resolve(self.release(asset={"name": "Other.AppImage"}))

    def test_refuses_unexpected_url(self):
        with self.assertRaises(YoError):
            self.resolve(self.release(asset={"browser_download_url": "https://example.com/Tool.AppImage"}))


class Coercion(unittest.TestCase):
    def test_kinds(self):
        self.assertIs(edit.coerce({"name": "a", "kind": "bool"}, "on"), True)
        self.assertEqual(edit.coerce({"name": "a", "kind": "enum", "choices": ["x", "y"]}, "y"), "y")
        self.assertEqual(edit.coerce({"name": "a", "kind": "enums", "choices": ["x", "y"]}, "y x"), ["y", "x"])
        self.assertEqual(edit.coerce({"name": "a", "kind": "int"}, "7"), 7)
        with self.assertRaises(YoError):
            edit.coerce({"name": "a", "kind": "enum", "choices": ["x"]}, "z")
        with self.assertRaises(YoError):
            edit.coerce({"name": "a", "kind": "bool"}, "maybe")


class Cache(unittest.TestCase):
    def test_foreign_entries_are_found(self):
        import os
        import tempfile
        from pathlib import Path

        from yo import repo
        with tempfile.TemporaryDirectory() as directory:
            cache = Path(directory) / "nix"
            (cache / "fetcher-locks").mkdir(parents=True)
            (cache / "eval-cache-v6").mkdir()
            (cache / "eval-cache-v6" / "a.sqlite").write_text("")
            with mock.patch.dict(os.environ, {"XDG_CACHE_HOME": directory}):
                self.assertEqual(repo.nix_cache_dir(), cache)
                self.assertEqual(repo.foreign_cache_entries(), [])
                # Seen as another user, all of it is foreign.
                foreign = repo.foreign_cache_entries(uid=os.getuid() + 1)
                self.assertIn(cache / "fetcher-locks", foreign)
                self.assertIn(cache / "eval-cache-v6" / "a.sqlite", foreign)

    def test_root_does_not_inherit_user_directories(self):
        command = system.elevate(["nixos-rebuild", "switch"])
        joined = " ".join(command)
        for name in system.USER_DIRECTORIES:
            self.assertIn(f"-u {name}", joined)
        self.assertEqual(command[-2:], ["nixos-rebuild", "switch"])


class FakeRepo:
    sets = {
        "dev.bundle": {"kind": "data", "default": False, "packages": {"agent": ["basic"]}, "sets": ["dev.python", "dev.rust"]},
        "dev.python": {"kind": "data", "default": False, "packages": {"python": ["basic"]}, "sets": []},
        "dev.rust": {"kind": "module"},
        "general.core": {"kind": "data", "default": True, "packages": {"vim": ["basic"]}, "sets": []},
    }

    def __init__(self, shared, machine):
        self.layers = {True: shared, False: machine}

    def profile_entry(self, ref, shared=False):
        return {"data": {"value": self.layers[shared]}}


class Selection(unittest.TestCase):
    REF = ProfileRef("user", "box")

    def test_layers_and_members(self):
        repo = FakeRepo(
            {"modules": {"dev": {"bundle": {"enable": True}}}, "packages": {"git": ["basic", "user"]}, "exclude": {}},
            {"modules": {"dev": {"python": {"enable": False}}}, "packages": {}, "exclude": {"vim": ["basic"]}},
        )
        selection = static_selection(repo, self.REF)
        self.assertEqual(selection["sets"]["dev.bundle"], "your shared profile")
        self.assertEqual(selection["sets"]["general.core"], "on by default")
        self.assertEqual(selection["sets"]["dev.rust"], "set dev.bundle")
        self.assertNotIn("dev.python", selection["sets"])
        self.assertEqual(selection["packages"]["agent"], {"basic": ["set dev.bundle"]})
        self.assertEqual(selection["packages"]["git"]["user"], ["your shared profile"])
        self.assertNotIn("python", selection["packages"])
        self.assertEqual(selection["exclude"], {"vim": ["basic"]})


if __name__ == "__main__":
    unittest.main()
