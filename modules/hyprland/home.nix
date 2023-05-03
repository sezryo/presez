{ pkgs, lib, ... }:

{
  home.file.".config/hypr/hyprland.conf".source = ./myHypr.conf;
}
