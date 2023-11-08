{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "grim" "basic"

{
  home.packages = [ pkgs.grim ];
}
