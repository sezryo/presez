{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "neofetch" "basic"

{
  home.packages = [ pkgs.neofetch ];
}
