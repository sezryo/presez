{ config, pkgs, lib, ... }:

# These are modules used across all devices on system level

with import ../functions;

{
  imports = useSystemModules [

    # Steam
    "steam" "gamescope"

    # System
    "flatpak" "xonsh"

    # Desktop environment services
    "hyprland" "xdotool" "wmctrl" "blueman" "dbus" "upower"
  ];
}