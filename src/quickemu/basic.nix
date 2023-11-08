{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "quickemu" "basic"

{
  home.packages = [ pkgs.quickemu ];
}
