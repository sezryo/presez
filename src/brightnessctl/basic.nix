{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "brightnessctl" "basic"

{
  home.packages = [ pkgs.brightnessctl ];
}
