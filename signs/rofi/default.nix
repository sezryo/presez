{ pkgs, lib, ... }:

{
  programs.rofi = {
    enable = true;
  };

  home.packages = [ pkgs.rofi ];
}
