{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.hardware.hdd;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.hardware.hdd = {
    enable = mkEnableOpt "You may need this to optimise a device with hdd";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      hdapsd = [ "basic" ]; # Hard disk protection if the laptop falls
    };
  };
}
