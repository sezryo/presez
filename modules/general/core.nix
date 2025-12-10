{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.general.core;
  inherit (lib.mine) mkEnableOpt' mkOpt';
in {
  options.modules.general.core = {
    enable = mkEnableOpt' "Enable core utilities for a well-functioning linux desktop, potential risks exist if not enabled";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      gnumake = [ "basic" ];
      cachix = [ "basic" ];
      electron = [ "basic" ];
      dig = [ "basic" ];
      vim = [ "basic" ];
      lunarvim = [ "basic" ];
      wget = [ "basic" ];
      firefox = [ "basic" ];
      binutils = [ "basic" ];
      coreutils = [ "basic" ];
      pciutils = [ "basic" ];
      usbutils = [ "basic" ];
      findutils = [ "basic" ];
      gawk = [ "basic" ];
      cached-nix-shell = [ "basic" ];
      flatpak = [ "basic" ];
      neofetch = [ "basic" ];
      hyfetch = [ "basic" ];
      baobab = [ "basic" ];
    };
  };
}
