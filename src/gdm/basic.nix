{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gdm" "basic"

{
  services.xserver.displayManager.gdm.enable = true;
}

