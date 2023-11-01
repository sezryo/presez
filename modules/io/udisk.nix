{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.io.udisk;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.io.udisk = {
    enable = mkEnableOpt "Whether to enable USB stick related tools";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      udisks = [ "basic" ];
      ventoy = [ "basic" ];
    };
  };
}
