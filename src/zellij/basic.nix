{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "zellij" "basic"

{
  home.packages = [ pkgs.zellij ];
}
