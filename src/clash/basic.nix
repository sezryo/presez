{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "clash" "basic"

{
  systemd.services.clash = {
    description = "Clash client service, using clash-meta";
    wantedBy = [ "multi-user.target" ]; 
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      ExecStart = "${pkgs.clash-meta}/bin/clash-meta -d " + "${config.user.configDir}/clash/";
      Restart = "on-failure";
      RestartPreventExitStatus = "23";
    };
  };
  
  environment.systemPackages = with pkgs; [
    clash-meta
  ];
}
