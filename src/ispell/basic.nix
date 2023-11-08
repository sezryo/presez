{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "ispell" "basic"

{
  home.packages = [ pkgs.ispell ];
}
