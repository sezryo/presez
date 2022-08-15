{ config, pkgs, lib, ... }:

{
  imports = [
    ./illusion.nix
    # ./spectacle.nix
    ./panopticon.nix
    ./significants.nix
  ];
}
