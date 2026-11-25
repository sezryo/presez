{ config, lib, pkgs, inputs, ... }:

{
  services = {
    avahi.enable = true;
    avahi.nssmdns4 = true;
    # for a WiFi printer
    avahi.openFirewall = true;
  };
}
