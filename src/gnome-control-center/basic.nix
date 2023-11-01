{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gnome-control-center" "basic"

{
  home.packages = [ pkgs.gnome.gnome-control-center ];
}
