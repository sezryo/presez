{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.purescript;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.purescript = {
    enable = mkEnableOpt "Whether to enable purescript toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      purescript = [ "basic" ];
      # spago = [ "basic" ];
      dhall = [ "basic" ];
      dhall-nix = [ "basic" ];
      psc-package = [ "basic" ];
    };
  };
}
