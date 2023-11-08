{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "gnome" "basic"
  
{ 
  services.xserver.desktopManager.gnome.enable = true;
}
