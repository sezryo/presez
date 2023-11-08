{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "sd" "basic"

{
  home.packages = [ pkgs.sd ];
}
