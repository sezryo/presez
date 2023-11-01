{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.hardware.ssd;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.hardware.ssd = {
    enable = mkEnableOpt "You may need this to optimise a device with ssd";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      fstrim = [ "basic" ];
    };
  };
}
