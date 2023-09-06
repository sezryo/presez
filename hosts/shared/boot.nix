{ config, pkgs, ... }:

{
  boot = {
    loader.grub = {
      enable = true;
      # version = 2;
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
      # fontSize = 16;
      configurationLimit = 30;      
    };
    loader.efi.efiSysMountPoint = "/boot";
    kernelPackages = pkgs.linuxPackages_latest;
  };
}
