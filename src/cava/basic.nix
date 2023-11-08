{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "cava" "basic"

{
  home.packages = [ pkgs.cava ];
}
