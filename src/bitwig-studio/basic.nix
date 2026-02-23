{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "bitwig-studio" "basic"

{
  home.packages = [ pkgs.bitwig-studio ];
}
