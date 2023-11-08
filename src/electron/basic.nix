{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "electron" "basic"
  
{
  home.packages = [ pkgs.electron ];
}
