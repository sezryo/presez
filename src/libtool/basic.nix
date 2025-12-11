{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "libtool" "basic"

{
  home.packages = [ pkgs.libtool ];
}
