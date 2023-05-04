{ pkgs, lib, config, inputs, ... }:

{
  imports =
    [
      ./env.nix
      ./cursor.nix
    ];

  home.username = "sezrienne";
  home.homeDirectory = "/home/sezrienne";
  home.stateVersion = "22.05";
}
