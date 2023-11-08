{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "ipp-usb" "basic"

{
  services.ipp-usb.enable = true;
}
