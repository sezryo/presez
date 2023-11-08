{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "bottles" "basic"

{
  home.packages = [ pkgs.bottles ];
}
