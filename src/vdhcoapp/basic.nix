{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "vdhcoapp" "basic"

{
  home.packages = [ pkgs.vdhcoapp ];
}
