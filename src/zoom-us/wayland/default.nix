{ config, lib, pkgs, inputs, ... }:

{
  home.configFile."zoomus.conf".source = ./myZoomus.conf;
  home.desktopEntries."zoom-wayland" = {
    name = "zoom-wayland";
    genericName = "Proprietary meeting app, lauching with wayland flags";
    exec = "zoom-us --enable-features=UseOzonePlatform --ozone-platform=wayland";
  };
}
