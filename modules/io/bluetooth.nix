{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.io.bluetooth;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.io.bluetooth = {
    enable = mkEnableOpt "Whether to enable bluetooth related tools";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      bluez = [ "basic" ];
      bluez-tools = [ "basic" ];
      blueberry = [ "basic" ];
      blueman = [ "basic" ];
    };
    hardware.bluetooth.enable = true;
  };
}
