{ pkgs, lib, ... }:

{
  programs.wezterm = {
    enable = true;
    extraConfig = builtins.readFile ./myWez.lua;
  };
}
