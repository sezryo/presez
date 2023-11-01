{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "udev" "disabled"

{
  runtime.control.udev.disabled = lib.mkDefault true;
}
