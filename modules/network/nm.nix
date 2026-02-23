{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.network.nm;
  inherit (lib.mine) mkEnableOpt mkEnableOpt';
in {
  options.modules.network.nm = {
    enable = mkEnableOpt "Whether to enable networkmanager services, not compatible with wireless";
    iwd.enable = mkEnableOpt "Whether to use iwd as wifi backend";
  };

  config = mkIf (cfg.enable && (!config.modules.network.wireless.enable)) (mkMerge [
    {
      networking.wireless.enable = mkDefault false;
      networking.networkmanager = {
        enable = true;
        wifi.macAddress = "stable";
        wifi.scanRandMacAddress = true;
        ethernet.macAddress = "random";
      };
      users.users.${config.user.name}.extraGroups = [ "networkmanager" ];
      users.groups.networkmanager.members = [ "root" ];
      
    }
    (mkIf cfg.iwd.enable {
      networking.networkmanager = {
        wifi.backend = "iwd";
      };
    })
  ]);
}
