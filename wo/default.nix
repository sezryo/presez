{ config, pkgs, lib, ... }:

{
  imports = [
    ./escape.nix
    ./intersubjectivity.nix
    ./lexicon.nix
  ];
}
