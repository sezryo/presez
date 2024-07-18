{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.bundle;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.bundle = {
    enable = mkEnableOpt "Whether to enable the default bundle of all the language supports";
  };

  config = mkIf cfg.enable {
    modules.dev = {
      agda.enable = true;
      c.enable = true;
      clojure.enable = true;
      coq.enable = true;
      elixir.enable = true;
      emacs.enable = true;
      git.enable = true;
      haskell.enable = true;
      nix.enable = true;
      ocaml.enable = true;
      purescript.enable = true;
      python.enable = true;
      racket.enable = true;
      ruby.enable = true;
      rust.enable = true;
      scala.enable = true;
      scheme.enable = true;
      tex.enable = true;
      typescript.enable = true;
    };
  };
}
