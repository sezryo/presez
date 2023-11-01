{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.hardware.power;
  inherit (lib.mine) mkEnableOpt mkOpt;
in {
  options.modules.hardware.power = {
    enable = mkEnableOpt "Whether to enable battery power related services";
    tuning = mkEnableOpt "Whether to use default service to manage power tuning";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.singleton = {
        powertop = [ "basic" ];
        upower = [ "basic" ];
      };
    }
    (mkIf cfg.tuning {
      modules.singleton = {
        tlp = [ "basic" ];
      };
    })
  ]);
}
