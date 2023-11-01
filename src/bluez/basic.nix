{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "bluez" "basic"

{
  home.packages = [ pkgs.bluez ];
}
