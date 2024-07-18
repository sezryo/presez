{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "scala" "basic"

{
  home.packages = [ pkgs.scala_3 ];
}
