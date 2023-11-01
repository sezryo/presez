{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "bluez-tools" "disabled"

{
  runtime.control.bluez-tools.disabled = lib.mkDefault true;
}
