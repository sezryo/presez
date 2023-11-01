{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "graphviz" "basic"

{
  home.packages = [ pkgs.graphviz ];
}
