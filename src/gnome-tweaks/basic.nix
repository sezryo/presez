{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gnome-tweaks" "basic"

{
  home.packages = [ pkgs.gnome.gnome-tweaks ];
}
