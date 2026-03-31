{ config, pkgs, lib, inputs, options, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.mine) mkEnableOpt;

  cfg = config.modules.io.bluetooth;
in {
  options.modules.io.bluetooth = {
    enable = mkEnableOpt "Whether to enable bluetooth related tools";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      bluez = [ "basic" ];
      bluez-tools = [ "basic" ];
      blueman = [ "basic" ];
    };
    hardware.bluetooth.enable = true;
  };
}
