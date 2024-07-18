{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "alacritty" "defaultSettings"
{
  home.configFile."alacritty/alacritty.toml".source = ./alacritty.toml;
}
