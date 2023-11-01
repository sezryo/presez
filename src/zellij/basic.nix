{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "zellij" "basic"

{
  home.packages = [ pkgs.zellij ];
}
