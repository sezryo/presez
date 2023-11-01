{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "dbus" "disabled"

{
  runtime.control.dbus.disabled = lib.mkDefault true;
}
