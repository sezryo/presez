{ config, pkgs, lib, inputs, options, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.mine) mkEnableOpt';

  cfg = config.modules.boot.systemd-boot;
in {
  options.modules.boot.systemd-boot = {
    enable = mkEnableOpt' "Whether to enable systemd-boot as boot loader";
  };

  config = mkIf cfg.enable {
    boot = {
      tmp.cleanOnBoot = true;
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
