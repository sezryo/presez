{ config, pkgs, ... }:

{
  networking.hostName = "sezrix";
  networking.wireless.enable = false;
  # networking.wireless.iwd.enable = true;
  networking.networkmanager = {
    enable = true;
    wifi.macAddress = "random";
    # wifi.backend = "iwd";
    ethernet.macAddress = "random";
  };
  networking.firewall = {
    allowedTCPPorts = [ 57621 ]; # For Spotify local discovery
  };

  services.openssh = {
    enable = true;
  };
  users.groups.networkmanager.members = [ "root" "sezrienne" ];
}
