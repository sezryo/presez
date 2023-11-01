{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "sddm" "basic"

{
  services.xserver.displayManager.sddm = {
    enable = true;
    enableHidpi = true;
  };
}
