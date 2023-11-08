{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "sddm" "basic"

{
  services.xserver.displayManager.sddm = {
    enable = true;
    enableHidpi = true;
  };
}
