{ config, lib, pkgs, inputs, ... }:

{
  home.packages = [ pkgs.emacsPackages.tuareg ];
}
