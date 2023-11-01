{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "wmctrl" "basic"

{
  environment.systemPackages = [ pkgs.wmctrl ];
}
