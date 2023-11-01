{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "bottles" "basic"

{
  home.packages = [ pkgs.bottles ];
}
