{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "hyfetch" "basic"

{
  home.packages = [ pkgs.hyfetch ];
}
