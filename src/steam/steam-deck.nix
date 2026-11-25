{ config, lib, pkgs, inputs, ... }:

{
  home.desktopEntries."steam-deck" = {
    name = "Steam-deck";
    genericName = "Proprietary gaming library, launching in steam deck mode";
    exec = "gamescope -e -f -- steam -gamepadui";
  };
}
