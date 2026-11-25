{
  description = "the default bundle of every language toolchain and coding agent";
  packages = [
    "antigravity"
    "claude-code"
    "claude-desktop"
    "claude-cowork"
    "t3code"
  ];
  sets = [
    "dev.agda"
    "dev.c"
    "dev.clojure"
    "dev.coq"
    "dev.elixir"
    "dev.emacs"
    "dev.git"
    "dev.haskell"
    "dev.nix"
    "dev.ocaml"
    # "dev.purescript" # upstream purescript 0.15.15 segfaults during install
    "dev.python"
    "dev.racket"
    "dev.ruby"
    "dev.rust"
    "dev.scala"
    # "dev.scheme"
    "dev.tex"
    "dev.typescript"
  ];
}
