{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    ./signs.nix
    ./incarnation.nix
    ./scripture.nix
  ];

  home.username = "sezrienne";
  home.homeDirectory = "/home/sezrienne";
  programs.home-manager.enable = true;

  home.stateVersion = "22.11";
}
