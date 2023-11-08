{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "brightnessctl" "basic"

{
  home.packages = [ pkgs.brightnessctl ];
}
