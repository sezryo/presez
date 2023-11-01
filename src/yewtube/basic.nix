{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "yewtube" "basic"

{
  home.packages = [ pkgs.yewtube ];
}
