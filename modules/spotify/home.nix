{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.spotify ];

  xdg.desktopEntries."spotify-wayland" = {
    name = "spotify-wayland";
    genericName = "Proprietary musics, lauching with flatpak";
    exec = "spotify --enable-features=UseOzonePlatform --ozone-platform=wayland";
  };
}
