{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.spotify ];

  xdg.desktopEntries."spotify-flatpak" = {
    name = "Spotify-flatpak";
    genericName = "Proprietary musics, lauching with flatpak";
    exec = "flatpak run com.spotify.Client";
  };
}
