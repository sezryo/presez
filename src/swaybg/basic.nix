{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "swaybg" "basic"

{
  home.packages = [ pkgs.swaybg ];
}
