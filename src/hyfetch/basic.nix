{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "hyfetch" "basic"

{
  home.packages = [ pkgs.hyfetch ];
}
