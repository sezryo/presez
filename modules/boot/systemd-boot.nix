{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;

let
  cfg = config.modules.boot.systemd-boot;
  inherit (lib.mine) mkEnableOpt mkEnableOpt' mkOpt';
in {
  options.modules.boot.systemd-boot = {
    enable = mkEnableOpt' "Whether to enable systemd-boot as boot loader";
  };

  config = mkIf cfg.enable {
    boot = {
      loader.systemd-boot = {
        enable = true;
        consoleMode = "auto";
      }; 
      loader.efi = {
	efiSysMountPoint = "/boot";
	canTouchEfiVariables = true;
      };
    };
  };
}
