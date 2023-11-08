{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "gnuplot" "basic"

{
  home.packages = [ pkgs.gnuplot ];
}
