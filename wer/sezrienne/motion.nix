{ config, pkgs, lib, ... }:

{
  imports = [ ../../wie/signifiers.nix ];
  home.username = "sezrienne";
  home.homeDirectory = "/home/sezrienne";
  home.stateVersion = "22.11";
}
