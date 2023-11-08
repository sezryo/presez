{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "wmctrl" "basic"

{
  environment.systemPackages = [ pkgs.wmctrl ];
}
