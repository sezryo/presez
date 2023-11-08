{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "eww" "basic"

{
  home.programs.eww = {
    enable = true;
    package = lib.mkIf config.modules.desktop.wayland.enable pkgs.eww-wayland; 
  };
}
