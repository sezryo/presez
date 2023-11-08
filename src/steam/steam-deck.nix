{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "steam" "steam-deck"

{
  home.desktopEntries."steam-deck" = {
    name = "Steam-deck";
    genericName = "Proprietary gaming library, launching in steam deck mode";
    exec = "gamescope -e -f -- steam -gamepadui";
  };
}
