{ inputs, pkgs, config, lib, ... }:

#TODO: Configure a minimum desktop environment
let
  inherit (lib.mine) rakeLeaves;
  ich = rakeLeaves ./.;
in {
  imports = with ich; [
    home boot env gc network packages security xserver options
  ];
  
  system.stateVersion = "22.05";
}
