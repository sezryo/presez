{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "blueberry" "basic"

{
  home.packages = [ pkgs.blueberry ];
}
