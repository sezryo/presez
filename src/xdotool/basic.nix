{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "xdotool" "basic"

{
  environment.systemPackages = [ pkgs.xdotool ];
}
