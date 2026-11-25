{ config, lib, pkgs, inputs, ... }:

{
  home.packages = with pkgs; [ yubikey-personalization yubikey-manager yubico-pam];
}
