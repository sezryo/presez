{ pkgs, lib, ... }:

{
  services.udev = {
    enable = true;
    packages = with pkgs; [
      yubikey-personalization
      libyubikey
    ];
  };
}
