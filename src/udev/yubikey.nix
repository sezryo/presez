{ config, lib, pkgs, inputs, ... }:

{
  services.udev = {
    packages = with pkgs; [
      yubikey-personalization
      libyubikey
    ];
  };
}
