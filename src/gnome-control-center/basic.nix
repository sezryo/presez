{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "gnome-control-center" "basic"

{
  home.packages = [ pkgs.gnome.gnome-control-center ];
}
