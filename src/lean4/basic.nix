{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "lean4" "basic"

{
  home.packages = [ pkgs.lean4 ];
}
