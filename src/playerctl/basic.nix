{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "playerctl" "basic"

{
  home.packages = [ pkgs.playerctl ];
}
