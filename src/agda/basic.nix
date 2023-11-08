{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "agda" "basic"

{
  home.packages = [ pkgs.agda ];
}
