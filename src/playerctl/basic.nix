{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "playerctl" "basic"

{
  home.packages = [ pkgs.playerctl ];
}
