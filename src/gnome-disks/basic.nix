{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "gnome-disks" "basic"

{
  home.packages = [ pkgs.gnome-disk-utility ];
}
