{ pkgs, lib, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    terminal = "wezterm";
  };

  home.file.".config/rofi" = {
    source = ./myRofi;
    recursive = true;
  };
}
