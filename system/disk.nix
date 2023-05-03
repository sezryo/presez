{ config, pkgs, ... }:

{
  nix.gc = {
    automatic = true;
    randomizedDelaySec = "14m";
    options = "--delete-older-than 30d";
  };
}
