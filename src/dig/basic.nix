{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "dig" "basic"

{
  home.packages = [ pkgs.dig ];
}
