{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "yarn" "basic"

{
  home.packages = [ pkgs.yarn ];
}
