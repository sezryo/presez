{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "yubikey" "basic"

{
  home.packages = with pkgs; [ yubikey-personalization yubikey-manager yubico-pam];
}
