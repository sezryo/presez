{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "wezterm" "defaultSettings"
{
  home.programs.wezterm = {
    extraConfig = builtins.readFile ./myWez.lua;
  };
}
