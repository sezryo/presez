{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules.singleton "rime" "basic"
  
{
  home.packages = [ pkgs.rime-cli pkgs.rime-data ];
}
