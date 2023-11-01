{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "krusader" "basic"

{
  home.packages = [ pkgs.krusader ];
}
