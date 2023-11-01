{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "spago" "basic"

{
  home.packages = [ pkgs.spago ];
}
