{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "hyprland" "osaka-night"
{
  home.configFile."hypr/hyprland.conf".source = ./myHypr.conf;
}
