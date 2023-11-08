{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "xdotool" "basic"

{
  environment.systemPackages = [ pkgs.xdotool ];
}
