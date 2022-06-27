{ config, lib, pkgs, ... }:

let

  cfg = config.services.supergfxd;

in
{
  options.services.supergfxd.enable = lib.mkEnableOption "ASUS GPU Switch";

  config = lib.mkIf cfg.enable {
    systemd.services.supergfxd = {
      description = "ASUS GPU Switch";
      before = [ "multi-user.target" ];
      startLimitIntervalSec = 200;
      startLimitBurst = 2;
      environment."IS_SERVICE" = "1";
      serviceConfig = {
        ExecStart = "${pkgs.supergfxctl}/bin/supergfxd";
        Restart = "on-failure";
        RestartSec = 1;
        Type = "dbus";
        BusName = "org.asuslinux.Daemon";
        SELinuxContext = "system_u:system_r:unconfined_t:s0";
      };
    };

    services.dbus.packages = [ pkgs.supergfxctl ]; 
  };
}
