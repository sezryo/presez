{ config, lib, pkgs, inputs, ... }:

{
  home.packages = [ pkgs.kdePackages.okular ];
}
