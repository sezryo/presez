{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "xvidcore" "basic"

{
  home.packages = [ pkgs.xvidcore ];
}
