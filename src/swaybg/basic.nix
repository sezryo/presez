{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "swaybg" "basic"

{
  home.packages = [ pkgs.swaybg ];
}
