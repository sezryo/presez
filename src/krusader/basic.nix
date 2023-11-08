{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "krusader" "basic"

{
  home.packages = [ pkgs.krusader ];
}
