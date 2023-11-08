{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "zip" "basic"

{
  home.packages = [ pkgs.zip ];
}
