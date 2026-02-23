{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "zenity" "basic"

{
  home.packages = [ pkgs.zenity ];
}
