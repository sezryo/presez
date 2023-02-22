{ config, pkgs, lib, ... }:

{
  services.xserver = {
    enable = true;
    exportConfiguration = true;
    displayManager.lightdm.enable = true;
  };
}
