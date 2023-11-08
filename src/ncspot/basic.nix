{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "ncspot" "basic"

{
  home.packages = [ pkgs.ncspot ];
}
