{ config, lib, pkgs, inputs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        gamescope
      ];
    };
  };
}
