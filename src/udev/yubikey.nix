{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "udev" "yubikey"

{
  services.udev = {
    packages = with pkgs; [
      yubikey-personalization
      libyubikey
    ];
  };
}
