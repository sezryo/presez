{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "lm_sensors" "basic"

{
  home.packages = [ pkgs.lm_sensors ];
}
