{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "electron" "basic"
  
{
  home.packages = [ pkgs.electron ];
}
