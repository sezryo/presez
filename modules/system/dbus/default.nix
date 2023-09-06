{ pkgs, lib, ... }:

{
  services.dbus = {
    enable = true;
  };
}