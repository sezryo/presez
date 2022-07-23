{ config, pkgs, lib, ... }:

with import ../morphisms;

{
  imports = listDir ../signs ++ listDir ../lingua;

  home.username = "sezrienne";
  home.homeDirectory = "/home/sezrienne";
  programs.home-manager.enable = true;

  home.stateVersion = "22.11";
}
