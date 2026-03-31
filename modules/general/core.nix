{ config, pkgs, lib, inputs, options, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.mine) mkEnableOpt';

  cfg = config.modules.general.core;
in {
  options.modules.general.core = {
    enable = mkEnableOpt' "Enable core utilities for a well-functioning linux desktop";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      gnumake = [ "basic" ];
      zenity = [ "basic" ];
      cachix = [ "basic" ];
      electron = [ "basic" ];
      dig = [ "basic" ];
      vim = [ "basic" ];
      wget = [ "basic" ];
      firefox = [ "basic" ];
      binutils = [ "basic" ];
      coreutils = [ "basic" ];
      pciutils = [ "basic" ];
      usbutils = [ "basic" ];
      findutils = [ "basic" ];
      libtool = [ "basic" ];
      gawk = [ "basic" ];
      cached-nix-shell = [ "basic" ];
      flatpak = [ "basic" ];
      hyfetch = [ "basic" ];
      baobab = [ "basic" ];
    };
  };
}
