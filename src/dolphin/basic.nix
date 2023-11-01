{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "dolphin" "basic"

{
  home.packages = [ pkgs.dolphin ];
}
