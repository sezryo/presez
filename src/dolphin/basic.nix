{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "dolphin" "basic"

{
  home.packages = [ pkgs.dolphin ];
}
