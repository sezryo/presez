{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "quickgui" "basic"

{
  home.packages = [ pkgs.quickgui ];
}
