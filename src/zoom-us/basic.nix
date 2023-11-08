{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "zoom-us" "basic"

{
  home.packages = [ pkgs.zoom-us ];
}
