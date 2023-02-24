{ config, pkgs, lib, ... }:

# These are modules used across all devices on system level

with import ../functions;

{
  imports = useSystemModules [

    # Steam
    "steam" "gamescope"

    # System
    "flatpak" "xonsh" "acpica-tools" "pcre"

    # Desktop environment services
    "hyprland" "xdotool" "wmctrl" "blueman" "dbus" "upower" "light"
  ];
}
