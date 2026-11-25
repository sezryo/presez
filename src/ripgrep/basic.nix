{ config, lib, pkgs, inputs, ... }:

{
  home.packages = [
    pkgs.ripgrep
    pkgs.emacsPackages.ripgrep
  ];
}
