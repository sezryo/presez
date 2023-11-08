{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "spotify" "basic"

{
  home.packages = [ pkgs.spotify ];

  home.desktopEntries."spotify-wayland" = {
    name = "spotify-wayland";
    genericName = "Proprietary musics, lauching with wayland flags";
    exec = "spotify --enable-features=UseOzonePlatform --ozone-platform=wayland";
  };
}
