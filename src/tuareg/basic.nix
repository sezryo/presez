{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "tuareg" "basic"

{
  home.packages = [ pkgs.emacsPackages.tuareg ];
}
