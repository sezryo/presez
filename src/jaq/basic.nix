{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "jaq" "basic"

{
  home.packages = [ pkgs.jaq ];
}
