{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "zip" "basic"

{
  home.packages = [ pkgs.zip ];
}
