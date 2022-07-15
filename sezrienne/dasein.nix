# This dasein file is for asus rog laptops with amd cpu and amd gpu

{ config, pkgs, ... }:

{

  boot.loader.grub = {
      enable = true;
      version = 2;
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
      theme = pkgs.nixos-grub2-theme;
    };
  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.printing.enable = true;
  services.asusd.enable = true;
  services.supergfxd.enable = true;
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  environment.systemPackages = with pkgs; [
    asusctl supergfxctl mesa mesa-demos
  ];

}
