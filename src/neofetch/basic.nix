{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "neofetch" "basic"

{
  home.packages = [ pkgs.neofetch ];
}
