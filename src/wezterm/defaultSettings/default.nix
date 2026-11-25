{ config, lib, pkgs, inputs, ... }:

{
  home.programs.wezterm = {
    extraConfig = builtins.readFile ./myWez.lua;
  };
}
