{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "spago" "basic"

{
  home.packages = [ pkgs.spago ];
}
