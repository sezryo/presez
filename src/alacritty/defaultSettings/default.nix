{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "alacritty" "defaultSettings"
{
  home.configFile."alacritty/alacritty.yml".source = ./init.yml;
}
