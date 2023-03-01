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

  services.openssh.enable = true;
  users.groups.networkmanager.members = [ "root" "sezrienne" ];
}
