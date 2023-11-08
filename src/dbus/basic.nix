{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "dbus" "basic"

{
  services.dbus = {
    enable = true;
  };
}
