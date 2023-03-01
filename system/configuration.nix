{ config, pkgs, lib, ... }:

{
  imports =
    [
      ./specialisation

      ./boot.nix
      ./hardware-configuration.nix
      ./users.nix
      ./xserver.nix
      ./security.nix
      ./proxy.nix
      ./network.nix
      ./i18n.nix
      ./io.nix
      ./env.nix
      ./virtualisation.nix
    ];
  
  system.stateVersion = "22.05";

}

