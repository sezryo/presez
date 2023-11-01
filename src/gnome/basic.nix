{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gnome" "basic"
  
{ 
  services.xserver.desktopManager.gnome.enable = true;
}
