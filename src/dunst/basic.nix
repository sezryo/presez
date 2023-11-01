{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "dunst" "basic"

{
  home.packages = [ pkgs.dunst ];
}
