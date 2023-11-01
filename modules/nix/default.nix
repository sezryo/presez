{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./channel.nix
    ./gc.nix
    ./localise.nix
  ];
}
