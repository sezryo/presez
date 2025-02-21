{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "netflix" "basic"

{
  home.packages = [ pkgs.netflix ];
}
