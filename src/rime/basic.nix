{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "rime" "basic"
  
{
  home.packages = [ pkgs.rime-cli pkgs.rime-data ];
}
