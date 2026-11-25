{ config, lib, pkgs, inputs, ... }:

{
  services.displayManager.sddm = {
    enable = true;
    enableHidpi = true;
  };
}
