{ config, lib, pkgs, inputs, ... }:

{
  home.configFile."hypr/hyprland.conf".source = ./myHypr.conf;
}
