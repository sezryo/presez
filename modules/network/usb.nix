{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.network.usb;
  inherit (lib.mine) mkEnableOpt mkEnableOptIf mkOpt mkOpt';
  kver = config.boot.kernelPackages.kernel.version;
in {
  options.modules.network.usb = {
    enable = mkEnableOpt "Whether to enable usb related services";
    thunderbolt = mkEnableOpt "Whether to enable thunderbolt related services";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.singleton = {
        iperf = [ "basic" ];
      };
    }
    (mkIf cfg.thunderbolt {
      modules.singleton = {
        boltd = [ "basic" ];
      };
    })
  ]);
}
