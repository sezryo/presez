{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "openssh" "basic"

{
  services.openssh = {
    enable = true;
    ports = [ 22 ]; 
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  services.fail2ban.enable = true;
}
