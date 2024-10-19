{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "sddm" "basic"

{
  services.displayManager.sddm = {
    enable = true;
    enableHidpi = true;
  };
}
