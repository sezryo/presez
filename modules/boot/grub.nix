{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;

let
  cfg = config.modules.boot.grub;
  inherit (lib.mine) mkEnableOpt mkEnableOpt' mkOpt';
  themes = [ "darkmatter-theme" ];
in {
  options.modules.boot.grub = {
    enable = mkEnableOpt' "Whether to enable basic grub settings as boot loader";
    efi = mkEnableOpt "Whether to enable efi related boot supports";
    theme = mkOpt' (enum themes) null "Which theme of grub to use";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      boot = {
        loader.grub = {
          enable = true;
          device = "nodev";
          configurationLimit = 30;      
        };
      };
    }
    (mkIf cfg.efi {
      boot = {
        loader.grub = {
          efiSupport = true;
          efiInstallAsRemovable = true;
        };
        loader.efi.efiSysMountPoint = "/boot";
      };
    })
    (mkIf (cfg.theme == "darkmatter-theme") {
      boot.loader.grub.darkmatter-theme = {
        enable = true;
        style = "nixos";
        icon = "color";
        resolution = "1440p";
      };
    })
  ]);
}
