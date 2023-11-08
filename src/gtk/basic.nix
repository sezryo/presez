{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "gtk" "basic"

{
  home.gtk = {
    enable = true;
  };
  home.packages = [ pkgs.gtk4 ];
}
