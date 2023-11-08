{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "gdm" "basic"

{
  services.xserver.displayManager.gdm.enable = true;
}

