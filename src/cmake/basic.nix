{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "cmake" "basic"

{
  home.packages = [ pkgs.cmake ];
}
