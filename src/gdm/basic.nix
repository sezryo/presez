{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "gdm" "basic"

{
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
}

