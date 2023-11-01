{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.general.system;
  inherit (lib.mine) mkEnableOpt' mkOpt';
in {
  options.modules.general.system = {
    enable = mkEnableOpt' "Enable system level utilities of a well-functioning linux desktop, potential risks exist if not enabled";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      dconf = [ "basic" ];
      udev = [ "basic" ];
      pcre = [ "basic" ];
      dbus = [ "basic" ];
      rtkit = [ "basic" ];
      lm_sensors = [ "basic" ];
    };
  };
}
