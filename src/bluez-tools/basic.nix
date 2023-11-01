{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "bluez-tools" "basic"

{
  home.packages = [ pkgs.bluez-tools ];
}
