import unittest

from yo import nixdata
from yo.nixdata import Document, NotData


PROFILE = '''\
# A machine profile.
{
  modules = {
    hardware = {
      x1nano2.enable = true; # the laptop
    };

    shell = {
      enable = true;
      env = [ "nushell" "bash" ];
    };
  };

  packages = [
    # "pluely"
    "sober"
    { git = [ "basic" "user" ]; }
    "tradingview" # charts
  ];
}
'''


def is_package(name):
    def matches(node, source):
        if isinstance(node, nixdata.Scalar):
            return source == nixdata.render(name)
        return [binding.path for binding in node.bindings] == [[name]]
    return matches


class Parsing(unittest.TestCase):
    def test_round_trip_positions(self):
        document = Document(PROFILE)
        binding, _, rest = nixdata.find(document.root, ["modules", "hardware", "x1nano2", "enable"])
        self.assertEqual(rest, [])
        self.assertEqual(PROFILE[binding.value.start:binding.value.end], "true")

    def test_rejects_functions(self):
        with self.assertRaises(NotData):
            Document("{ pkgs, ... }: { }")

    def test_rejects_interpolation(self):
        with self.assertRaises(NotData):
            Document('{ a = "${b}"; }')

    def test_rejects_operators(self):
        with self.assertRaises(NotData):
            Document('{ a = [ 1 ] ++ [ 2 ]; }')

    def test_comments_and_strings_with_braces(self):
        document = Document('{ a = "}"; /* } */ b = \'\'x } \'\'; # }\n}')
        self.assertTrue(document.has(["b"]))


class Editing(unittest.TestCase):
    def check(self, document, expected):
        self.assertEqual(nixdata.evaluate(document.text), expected)

    def base(self):
        return nixdata.evaluate(PROFILE)

    def test_set_existing_value(self):
        document = Document(PROFILE)
        document.set(["modules", "shell", "enable"], False)
        expected = self.base()
        expected["modules"]["shell"]["enable"] = False
        self.check(document, expected)
        self.assertIn("# the laptop", document.text)

    def test_set_through_dotted_binding(self):
        document = Document(PROFILE)
        document.set(["modules", "hardware", "x1nano2", "enable"], False)
        self.assertIn("x1nano2.enable = false; # the laptop", document.text)

    def test_set_new_nested_value(self):
        document = Document(PROFILE)
        document.set(["modules", "hardware", "vfio", "enable"], True)
        expected = self.base()
        expected["modules"]["hardware"]["vfio"] = {"enable": True}
        self.check(document, expected)
        self.assertIn("      vfio.enable = true;\n    };", document.text)

    def test_set_new_top_level_group(self):
        document = Document(PROFILE)
        document.set(["modules", "dev", "python", "enable"], True)
        expected = self.base()
        expected["modules"]["dev"] = {"python": {"enable": True}}
        self.check(document, expected)
        self.assertIn("    dev.python.enable = true;\n  };", document.text)

    def test_replace_list_value(self):
        document = Document(PROFILE)
        document.set(["modules", "shell", "env"], ["fish"])
        expected = self.base()
        expected["modules"]["shell"]["env"] = ["fish"]
        self.check(document, expected)

    def test_delete_prunes_empty_parents(self):
        document = Document(PROFILE)
        document.delete(["modules", "hardware", "x1nano2", "enable"])
        expected = self.base()
        del expected["modules"]["hardware"]
        self.check(document, expected)
        self.assertNotIn("hardware", document.text)

    def test_delete_keeps_siblings(self):
        document = Document(PROFILE)
        document.delete(["modules", "shell", "enable"])
        expected = self.base()
        del expected["modules"]["shell"]["enable"]
        self.check(document, expected)

    def test_list_add(self):
        document = Document(PROFILE)
        document.list_add(["packages"], "ripgrep")
        expected = self.base()
        expected["packages"].append("ripgrep")
        self.check(document, expected)
        self.assertIn('    "tradingview" # charts\n    "ripgrep"\n  ];', document.text)
        self.assertIn('# "pluely"', document.text)

    def test_list_add_variants(self):
        document = Document(PROFILE)
        document.list_add(["packages"], {"starship": ["basic", "catppuccin"]})
        expected = self.base()
        expected["packages"].append({"starship": ["basic", "catppuccin"]})
        self.check(document, expected)
        self.assertIn('    { starship = [ "basic" "catppuccin" ]; }\n  ];', document.text)

    def test_list_add_creates_list(self):
        document = Document('{\n  description = "x";\n}\n')
        document.list_add(["packages"], "bat")
        self.check(document, {"description": "x", "packages": ["bat"]})
        self.assertIn('  packages = [\n    "bat"\n  ];\n}', document.text)

    def test_list_add_to_inline_list(self):
        document = Document(PROFILE)
        document.list_add(["modules", "shell", "env"], "fish")
        self.assertIn('env = [ "nushell" "bash" "fish" ];', document.text)

    def test_list_remove_line(self):
        document = Document(PROFILE)
        self.assertTrue(document.list_remove(["packages"], is_package("tradingview")))
        expected = self.base()
        expected["packages"].remove("tradingview")
        self.check(document, expected)
        self.assertNotIn("charts", document.text)

    def test_list_remove_variant_entry(self):
        document = Document(PROFILE)
        self.assertTrue(document.list_remove(["packages"], is_package("git")))
        expected = self.base()
        expected["packages"] = ["sober", "tradingview"]
        self.check(document, expected)

    def test_list_remove_inline(self):
        document = Document(PROFILE)
        document.list_remove(["modules", "shell", "env"], is_package("nushell"))
        self.assertIn('env = [ "bash" ];', document.text)

    def test_list_remove_missing(self):
        document = Document(PROFILE)
        self.assertFalse(document.list_remove(["packages"], is_package("nope")))
        self.assertEqual(document.text, PROFILE)

    def test_empty_file(self):
        document = Document("{ }\n")
        document.set(["modules", "dev", "python", "enable"], True)
        self.check(document, {"modules": {"dev": {"python": {"enable": True}}}})
        self.assertEqual(document.text, "{\n  modules.dev.python.enable = true;\n}\n")

    def test_delete_one_of_several_dotted_definitions(self):
        document = Document("{\n  modules = {\n    dev.lean.enable = true;\n    dev.python.enable = false;\n  };\n}\n")
        document.delete(["modules", "dev", "lean", "enable"])
        self.check(document, {"modules": {"dev": {"python": {"enable": False}}}})
        document.delete(["modules", "dev", "python", "enable"])
        self.check(document, {})

    def test_spread_definition_is_refused(self):
        document = Document("{ a.b = 1; a.c = 2; }")
        with self.assertRaises(nixdata.EditError):
            document.set(["a"], {"d": 3})

    def test_render_escapes(self):
        self.assertEqual(nixdata.evaluate("{ a = " + nixdata.render('q"${x}\\') + "; }"), {"a": 'q"${x}\\'})

    def test_quoted_attribute_names(self):
        document = Document("{ }\n")
        document.set(["packages", "kdePackages.dolphin"], ["basic"])
        self.check(document, {"packages": {"kdePackages.dolphin": ["basic"]}})


if __name__ == "__main__":
    unittest.main()
