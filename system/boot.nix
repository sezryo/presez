# This dasein file is for asus rog laptops with amd cpu and amd gpu

{ config, pkgs, ... }:

{

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
      fontSize = 9;
    };
    # initrd.prepend = [ "${./acpi_override}" ];
    # kernelParams = [ "mem_sleep_default=deep" ];
    loader.efi.efiSysMountPoint = "/boot";
    # kernelParams = [ "early_initrd=acpi_override" "mem_sleep_default=deep" ];
    # kernelParams = [ "acpi_osi=" ];
    initrd.kernelModules = [ "amdgpu" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };
  services = {
    printing.enable = true;
    avahi.enable = true;
    # for a WiFi printer
    avahi.openFirewall = true;
    # for an USB printer
    ipp-usb.enable = true;
    asusd.enable = true;
    supergfxd.enable = true;
  };
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;

  environment.systemPackages = with pkgs; [ acpica-tools pcre ];

}
