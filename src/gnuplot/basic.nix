{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gnuplot" "basic"

{
  home.packages = [ pkgs.gnuplot ];
}
