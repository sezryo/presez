{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "bluez-tools" "basic"

{
  home.packages = [ pkgs.bluez-tools ];
}
