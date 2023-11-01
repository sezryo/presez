{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.dev.nix;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.dev.nix = {
    enable = mkEnableOpt "Whether to enable nix toolchain";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      nixfmt = [ "basic" ];
    };
  };
}
