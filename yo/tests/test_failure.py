import tempfile
import textwrap
import threading
import unittest
from pathlib import Path
from unittest import mock

from yo import failure
from yo.failure import Failed, explain
from yo.repo import YoError

# What `nix build` printed (Nix 2.36) when a flake input started to refuse its own module.
ASSERTION = textwrap.dedent("""\
    unpacking 'github:oxalica/rust-overlay/67021b279bfffe654a0201ede805748a255ae5a7' into the Git cache...
    error:
           … while calling the 'throw' builtin
             at /nix/store/qbr8hmkwvspln5nbs1qch660cfba6a1z-source/lib/asserts.nix:201:7:
              200|     if failedAssertions != [ ] then
              201|       throw "\\nFailed assertions:\\n${concatStringsSep "\\n" (map (x: "- ${x}") failedAssertions)}"
                 |       ^
              202|     else

           (stack trace truncated; use '--show-trace' to show the full, detailed trace)

           error:
           Failed assertions:
           - The Hyprland flake no longer provides a NixOS module.
           Remove `hyprland.nixosModules.default` from your imports and use the
           `programs.hyprland` module from nixpkgs instead. Set
           `programs.hyprland.package` to use the package from this flake.
    """)

UNDEFINED = textwrap.dedent("""\
    error:
           … while evaluating the option `home-manager.users.me.home.packages':

           … while evaluating definitions from `/nix/store/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-source/lib/sets.nix':

           error: undefined variable 'foo'
           at /nix/store/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-source/modules/dev/python.nix:5:17:
                4|   description = "the Python toolchain";
                5|   packages = [ foo ];
                 |                ^
                6| }
    """)

BUILD = textwrap.dedent("""\
    these 2 derivations will be built:
      /nix/store/3qwp9d2w1f15h34ai25ra57jb98h8qsc-t3code-0.1.12.drv
      /nix/store/smcc2ikknj204jww5l1fyy0ip22xzjs0-system-path.drv
    building '/nix/store/3qwp9d2w1f15h34ai25ra57jb98h8qsc-t3code-0.1.12.drv'...
    error: Cannot build '/nix/store/3qwp9d2w1f15h34ai25ra57jb98h8qsc-t3code-0.1.12.drv'.
           Reason: builder failed with exit code 2.
           Output paths:
             /nix/store/0lx1qbj39zwv9g0f48g7g93vwan2gyy8-t3code-0.1.12
           Last 25 log lines:
    {lines}
           > src/main.c:12:5: error: unknown type name 'foo'
           For full logs, run:
             nix log /nix/store/3qwp9d2w1f15h34ai25ra57jb98h8qsc-t3code-0.1.12.drv
    error: Cannot build '/nix/store/smcc2ikknj204jww5l1fyy0ip22xzjs0-system-path.drv'.
           Reason: 1 dependency failed.
           Output paths:
             /nix/store/sy1xf5yy7g45wa7ihvj1qmbynrki807a-system-path
    """).replace("{lines}", "\n".join(f"       > compiling unit {number}" for number in range(1, 25)))

OLD_BUILD = textwrap.dedent("""\
    error: builder for '/nix/store/3qwp9d2w1f15h34ai25ra57jb98h8qsc-hello-2.12.drv' failed with exit code 1;
           last 2 log lines:
           > configure: error: no acceptable C compiler found in $PATH
           > See `config.log' for more details
           For full logs, run 'nix log /nix/store/3qwp9d2w1f15h34ai25ra57jb98h8qsc-hello-2.12.drv'.
    error: 1 dependencies of derivation '/nix/store/smcc2ikknj204jww5l1fyy0ip22xzjs0-system-path.drv' failed to build
    """)

HASH = textwrap.dedent("""\
    building '/nix/store/1889l7q96hm3axc415ml7608gjy44rn1-t3code-0.1.12.AppImage.drv'...
    error: hash mismatch in fixed-output derivation '/nix/store/1889l7q96hm3axc415ml7608gjy44rn1-t3code-0.1.12.AppImage.drv':
             specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
                got:    sha256-yc8GUKaCC1iflqkgYODrk3ECuAj0jNXj813LpEnqCkE=
    """)

OFFLINE = textwrap.dedent("""\
    building '/nix/store/0hqvijb764724y7y26sc456335rh80va-file.tar.gz.drv'...
    error: Cannot build '/nix/store/0hqvijb764724y7y26sc456335rh80va-file.tar.gz.drv'.
           Reason: builder failed with exit code 1.
           Last 3 log lines:
           > trying https://example.invalid/file.tar.gz
           > curl: (6) Could not resolve host: example.invalid
           > error: cannot download file.tar.gz from any mirror
           For full logs, run:
             nix log /nix/store/0hqvijb764724y7y26sc456335rh80va-file.tar.gz.drv
    """)


class Tree(unittest.TestCase):
    """A small configuration to point into."""

    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.root = Path(self.directory.name)
        files = {
            "flake.nix": "{ }\n",
            "src/hyprland/basic.nix": "{ inputs, ... }:\n\n{\n  imports = [ inputs.hyprland.nixosModules.default ];\n}\n",
            "src/t3code/basic.nix": "{ }\n",
            "src/t3code/meta.nix": "{ }\n",
            "modules/dev/python.nix": "{\n}\n",
            "notes/old.nix": "# hyprland.nixosModules.default used to be imported here\n",
        }
        for name, text in files.items():
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text)

    def tearDown(self):
        self.directory.cleanup()


class Evaluation(Tree):
    def test_failed_check_is_told_without_the_trace(self):
        found = explain(ASSERTION, self.root, "me-laptop")
        self.assertEqual(found.phase, "evaluate")
        self.assertEqual(found.title, "The Configuration Fails a Check")
        self.assertEqual(found.message.splitlines()[0], "Failed assertions:")
        self.assertEqual(found.message.splitlines()[-1],
                         "`programs.hyprland.package` to use the package from this flake.")
        self.assertNotIn("asserts.nix", found.message)
        self.assertIn("stack trace truncated", found.log)

    def test_names_quoted_by_a_check_lead_to_the_file_using_them(self):
        found = explain(ASSERTION, self.root)
        self.assertEqual([(place.file, place.line) for place in found.places], [("src/hyprland/basic.nix", 4)])
        self.assertEqual(found.places[0].why, "uses hyprland.nixosModules.default")

    def test_the_configurations_own_check_leads_to_the_selection(self):
        (self.root / "profiles/me/laptop").mkdir(parents=True)
        (self.root / "profiles/me/laptop/profile.nix").write_text(
            '{\n  packages = [\n    # "nosuch"\n    "nosuch"\n    { git = [ "basic" "fancy" ]; }\n  ];\n}\n')
        unknown = ("error:\n       error:\n       Failed assertions:\n"
                   "       - Selected packages that are neither in src/ nor in nixpkgs: nosuch\n"
                   "       - Selected package variants that do not exist under src/: git.fancy\n")
        found = explain(unknown, self.root)
        self.assertEqual([(place.file, place.line, place.why) for place in found.places], [
            ("profiles/me/laptop/profile.nix", 4, "selects nosuch"),
            ("profiles/me/laptop/profile.nix", 5, "selects git"),
        ])

    def test_location_in_this_configuration(self):
        with mock.patch.object(failure._Trees, "ours", lambda self, store: store.endswith("-source")):
            found = explain(UNDEFINED, self.root, "me-laptop")
        self.assertEqual(found.title, "The Configuration Has an Error")
        self.assertIn("me-laptop", found.summary)
        self.assertEqual(found.message.splitlines()[:2],
                         ["undefined variable 'foo'", "at modules/dev/python.nix:5:17:"])
        self.assertIn("     |                ^", found.message)
        self.assertEqual([(place.file, place.line, place.why) for place in found.places],
                         [("modules/dev/python.nix", 5, "")])

    def test_someone_elses_store_path_is_not_ours(self):
        found = explain(UNDEFINED, self.root)     # /nix/store/aaaa…-source does not exist
        self.assertEqual(found.places, [])
        self.assertIn("/nix/store/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-source/modules/dev/python.nix", found.message)


class Building(Tree):
    def test_builder_failure(self):
        found = explain(BUILD, self.root, "me-laptop")
        self.assertEqual(found.phase, "build")
        self.assertEqual(found.title, "t3code-0.1.12 Did Not Build")
        lines = found.message.splitlines()
        self.assertEqual(lines[0], "The builder stopped with exit code 2. Its last lines:")
        self.assertEqual(lines[2], "…")
        self.assertEqual(lines[-1], "src/main.c:12:5: error: unknown type name 'foo'")
        self.assertEqual(len(lines), 3 + failure.TAIL)
        self.assertEqual(found.derivation, "/nix/store/3qwp9d2w1f15h34ai25ra57jb98h8qsc-t3code-0.1.12.drv")
        self.assertEqual(found.build_log, "nix log /nix/store/3qwp9d2w1f15h34ai25ra57jb98h8qsc-t3code-0.1.12.drv")
        self.assertEqual([place.file for place in found.places], ["src/t3code/basic.nix"])

    def test_older_wording(self):
        found = explain(OLD_BUILD)
        self.assertEqual(found.title, "hello-2.12 Did Not Build")
        self.assertIn("exit code 1", found.message)
        self.assertEqual(found.message.splitlines()[-1], "See `config.log' for more details")
        self.assertTrue(found.build_log.endswith("-hello-2.12.drv"))

    def test_hash_mismatch(self):
        found = explain(HASH, self.root)
        self.assertEqual(found.title, "t3code-0.1.12.AppImage Is Not What Was Pinned")
        self.assertIn("got:    sha256-yc8GUKaCC1iflqkgYODrk3ECuAj0jNXj813LpEnqCkE=", found.message)
        self.assertEqual(found.advice, ["If t3code is pinned here, refresh the pin with: yo update t3code"])

    def test_no_network(self):
        found = explain(OFFLINE)
        self.assertEqual(found.phase, "download")
        self.assertEqual(found.title, "file.tar.gz Could Not Be Downloaded")
        self.assertIn("Check the network connection and try again.", found.advice)

    def test_output_without_an_error_keeps_its_end(self):
        found = explain("copying path '/nix/store/x' from 'https://cache.nixos.org'...\nKilled\n")
        self.assertEqual(found.title, "The Build Failed")
        self.assertEqual(found.message, "Killed")


class Naming(unittest.TestCase):
    def test_names(self):
        self.assertEqual(failure.derivation_name("/nix/store/3qwp9d2w1f15h34ai25ra57jb98h8qsc-foo-bar-1.2.drv"),
                         "foo-bar-1.2")
        self.assertEqual(failure.package_name("python3.14-pygobject-3.58.0"), "python3.14-pygobject")
        self.assertEqual(failure.package_name("system-path"), "system-path")

    def test_any_error_becomes_a_failure(self):
        told = failure.of(YoError("Updating flake inputs failed:\nerror: unable to download"), "Updating", "Nothing built.")
        self.assertEqual((told.title, told.summary, told.message),
                         ("Updating Flake Inputs Failed", "Nothing built.", "error: unable to download"))
        plain = failure.of(YoError("Nothing called 'x' can be updated"))
        self.assertEqual((plain.title, plain.message), (failure.PLAIN, "Nothing called 'x' can be updated"))
        try:
            {}["missing"]
        except KeyError as error:
            fault = failure.of(error, "Building")
        self.assertEqual(fault.phase, "internal")
        self.assertEqual(fault.message, "KeyError: 'missing'")
        self.assertIn("Traceback", fault.log)

    def test_failed_reads_as_its_failure(self):
        found = explain(HASH)
        error = Failed(found)
        found.advice.append("Added later.")
        self.assertIs(failure.of(error), found)
        self.assertTrue(str(error).startswith("t3code-0.1.12.AppImage Is Not What Was Pinned\n"))
        self.assertTrue(str(error).endswith("Added later."))


class Delivery(unittest.TestCase):
    """What a background task raised must reach the window as it was raised.

    It once arrived as None, or not at all: the handler passed the main loop
    a function that looked the error up by the name of `except ... as error`,
    which Python unsets as soon as the handler is left.
    """

    def test_the_error_arrives(self):
        try:
            from gi.repository import GLib
            from yo.gui.util import first_line, run_async
        except (ImportError, ValueError) as error:
            self.skipTest(f"needs PyGObject with GTK 4 and libadwaita: {error}")
        loop = GLib.MainLoop()
        got = []
        release = threading.Event()

        def work():
            release.wait(5)             # fail while the main loop is running, as a build does
            raise Failed(explain(HASH))

        def failed(error):
            got.append(error)
            loop.quit()

        run_async(work, lambda _: loop.quit(), failed)
        GLib.idle_add(lambda: release.set() and False)
        GLib.timeout_add(5000, loop.quit)
        loop.run()
        self.assertEqual(len(got), 1)
        self.assertIsInstance(got[0], Failed)
        self.assertEqual(first_line(got[0]).split(":")[0], "t3code-0.1.12.AppImage Is Not What Was Pinned")


if __name__ == "__main__":
    unittest.main()
