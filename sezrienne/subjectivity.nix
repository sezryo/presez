{ config, pkgs, lib, ... }:

{
  imports =
    [ 
      ./existenz.nix
      ./dasein.nix
      ./symptoms.nix
      ./panopticon.nix
      ../objects.nix
      ../le-real/intersubjectivity.nix
      ../le-real/in-der-welt-sein.nix
      ../le-imaginare/ecstasy.nix
      # ../le-imaginare/societe/spectacle.nix
      ../le-imaginare/societe/illusion.nix
    ];
  
  system.stateVersion = "22.05";

}

