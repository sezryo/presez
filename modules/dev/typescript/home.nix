{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    nodejs-18_x yarn yarn2nix
    nodePackages_latest.pnpm
  ];
}
