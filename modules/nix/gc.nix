{ config, pkgs, lib, inputs, options, ... }:

with lib;

let
  cfg = config.modules.nix.gc;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.nix.gc = {
    enable = mkEnableOpt "Whether to enable automatic nixos garbage collection";
  };

  config = mkIf cfg.enable {
    nix.gc = {
      automatic = true;
      randomizedDelaySec = "14m";
      options = "--delete-older-than 30d";
    };
  };
}
