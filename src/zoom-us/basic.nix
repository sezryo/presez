{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "zoom-us" "basic"

{
  home.packages = [ pkgs.zoom-us ];
}
