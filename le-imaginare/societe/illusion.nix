{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;
    exportConfiguration = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  environment.systemPackages = with pkgs; [
    taffybar dmenu nitrogen alacritty rofi polybar
  ];
}
