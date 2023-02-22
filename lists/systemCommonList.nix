{ config, pkgs, lib, ... }:

# These are modules used across all devices on system level

with import ../functions;

{
  imports = useModules [    

    # Steam
    "steam" "gamescope"

    # Packaging
    "flatpak"

    # Desktop environment services
    "xdotool" "wmctrl" "blueman" "dbus" "upower"
  ];
}
