{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.io.printing;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.io.printing = {
    enable = mkEnableOpt "Whether to enable printing related services";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      avahi = [ "basic" ];
      ipp-usb = [ "basic" ]; # for an USB printer
    };
    services.printing.enable = true;
  };
}
