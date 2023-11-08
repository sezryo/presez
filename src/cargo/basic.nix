{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "cargo" "basic"

{
  home.packages = [ pkgs.cargo ];
}
