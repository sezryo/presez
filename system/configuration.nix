{ config, pkgs, lib, ... }:

{
  imports =
    [ 
      ./boot.nix
      ./hardware-configuration.nix
      ./users.nix
      ./xserver.nix
      ./unsafe.nix
      ./proxy.nix
      ./network.nix
      ./i18n.nix
      ./env.nix
    ];
  
  system.stateVersion = "22.05";

}

