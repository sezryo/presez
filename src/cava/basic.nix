{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "cava" "basic"

{
  home.packages = [ pkgs.cava ];
}
