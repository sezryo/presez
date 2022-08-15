{ config, pkgs, lib, ... }:

with import ../morphisms;

{
  imports = useSigns [
    "lightdm"
    "xmonad"
    "nm-applet"
    "picom"
    "nitrogen"
    "polybar"
  ];

  services.xserver = {
    enable = true;
    exportConfiguration = true;
    layout = "us";
    libinput.enable = true;
  };


  service.blueman.enable = true;
  service.dbus.enable = true;
  systemd.services.upower.enable = true;

}
