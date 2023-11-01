{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "steam" "gamescope"

{
  nixpkgs.config.packageOverrides = pkgs: {
    steam = pkgs.steam.override {
      extraPkgs = pkgs: with pkgs; [
        gamescope
      ];
    };
  };
}
