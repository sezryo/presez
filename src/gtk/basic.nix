{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gtk" "basic"

{
  home.gtk = {
    enable = true;
  };
  home.packages = [ pkgs.gtk4 ];
}
