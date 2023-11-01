{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "avahi" "basic"

{
  services = {
    avahi.enable = true;
    avahi.nssmdns = true;
    # for a WiFi printer
    avahi.openFirewall = true;
  };
}
