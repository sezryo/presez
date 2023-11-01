{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "bluez" "disabled"

{
  runtime.control.bluez.disabled = lib.mkDefault true;
}
