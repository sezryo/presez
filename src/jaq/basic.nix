{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "jaq" "basic"

{
  home.packages = [ pkgs.jaq ];
}
