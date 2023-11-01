{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "yubikey" "basic"

{
  home.packages = with pkgs; [ yubikey-personalization yubikey-manager yubico-pam];
}
