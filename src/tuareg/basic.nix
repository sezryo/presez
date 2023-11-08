{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "tuareg" "basic"

{
  home.packages = [ pkgs.emacsPackages.tuareg ];
}
