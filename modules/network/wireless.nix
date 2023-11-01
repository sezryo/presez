{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.network.wireless;
  inherit (lib.mine) mkEnableOpt mkEnableOpt';
in {
  options.modules.network.wireless = {
    enable = mkEnableOpt "Whether to enable wireless services, not compatible with networkmanager";
    iwd.enable = mkEnableOpt "Whether to use iwd as wifi backend";
  };

  config = mkIf (cfg.enable && (!modules.network.nm.enable)) (mkMerge [
    {
      networking.wireless.enable = true;
      networking.networkmanager.enable = false;
      users.users.${config.user.name}.extraGroups = [ "wireless" ];
    }
    (mkIf cfg.iwd.enable {
      networking.wireless = {
        iwd.enable = true;
      };
    })
  ]);
}
