{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "yewtube" "basic"

{
  home.packages = [ pkgs.yewtube ];
}
