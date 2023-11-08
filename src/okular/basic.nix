{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "okular" "basic"

{
  home.packages = [ pkgs.okular ];
}
