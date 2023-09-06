{ inputs, pkgs, config, lib, ... }:

let
  inherit (lib.mine) rakeLeaves;
  ich = rakeLeaves ./.;
in {
  imports = with ich; [
    options home boot env i18n proxy users virtualisation packages security
  ];
}
