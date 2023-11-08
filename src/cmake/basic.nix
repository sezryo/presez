{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "cmake" "basic"

{
  home.packages = [ pkgs.cmake ];
}
