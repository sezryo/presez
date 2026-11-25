{ config, lib, pkgs, inputs, ... }:

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
