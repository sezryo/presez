{ config, pkgs, lib, ... }:

# These are modules used across all devices on system level

with import ../functions;

{
  imports = useSystemModules [

    # Steam
    "steam" "gamescope"

    # System
    "flatpak" "xonsh" "qemu" "dconf"

    # Hardware
    "acpica-tools" "pcre" "supergfxd" "asusd"

    # Desktop environment services
    "hyprland" "xdotool" "wmctrl" "blueman" "dbus" "upower" "light"
  ];
}
