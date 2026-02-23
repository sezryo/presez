{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "reaper" "basic"

{
  home.packages = [ pkgs.reaper ];
}
