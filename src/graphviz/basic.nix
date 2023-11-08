{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "graphviz" "basic"

{
  home.packages = [ pkgs.graphviz ];
}
