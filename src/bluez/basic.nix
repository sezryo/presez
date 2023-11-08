{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "bluez" "basic"

{
  home.packages = [ pkgs.bluez ];
}
