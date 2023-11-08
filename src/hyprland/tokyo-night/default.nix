{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "hyprland" "tokyo-night"
{
  home.configFile."hypr/hyprland.conf".source = ./myHypr.conf;
}
