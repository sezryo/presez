{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.ocaml;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.ocaml = {
    enable = mkEnableOpt "Whether to enable ocaml toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      ocaml = [ "basic" ];
      opam = [ "basic" ];
      merlin = [ "basic" ];
      utop = [ "basic" ];
    };
  };
}
