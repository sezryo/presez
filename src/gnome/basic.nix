{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "gnome" "basic"
  
{ 
  services.desktopManager.gnome.enable = true;
}
