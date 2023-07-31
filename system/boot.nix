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

      darkmatter-theme = {
        enable = true;
        style = "nixos";
        icon = "color";
        resolution = "1440p";
      };
      
    };
    # initrd.prepend = [ "${./acpi_override}" ];
    # kernelParams = [ "mem_sleep_default=deep" ];
    loader.efi.efiSysMountPoint = "/boot";
    # kernelParams = [ "early_initrd=acpi_override" "mem_sleep_default=deep" ];
    # kernelParams = [ "acpi_osi=" ];
    initrd.kernelModules = [ "amdgpu" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };
}
