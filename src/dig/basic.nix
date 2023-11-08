{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "dig" "basic"

{
  home.packages = [ pkgs.dig ];
}
