{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ipp-usb" "disabled"

{
  runtime.control.ipp-usb.disabled = lib.mkDefault true;
}
