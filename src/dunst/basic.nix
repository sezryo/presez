{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "dunst" "basic"

{
  home.packages = [ pkgs.dunst ];
}
