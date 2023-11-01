{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "dbus" "basic"

{
  services.dbus = {
    enable = true;
  };
}
