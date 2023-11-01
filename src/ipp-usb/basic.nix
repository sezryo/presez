{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ipp-usb" "basic"

{
  services.ipp-usb.enable = true;
}
