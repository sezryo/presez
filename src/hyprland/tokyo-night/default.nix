{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "hyprland" "tokyo-night"
{
  home.configFile."hypr/hyprland.conf".source = ./myHypr.conf;
}
