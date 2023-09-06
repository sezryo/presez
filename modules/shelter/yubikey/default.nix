{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [ yubikey-personalization yubikey-manager yubico-pam];
}
