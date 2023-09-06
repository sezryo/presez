{ inputs, pkgs, config, lib, ... }:

let
  inherit (lib.mine) rakeLeaves;
  ich = rakeLeaves ./.;
in {
  imports = with ich; [
    boot
    configuration
    io
    specialisation
  ];
}
