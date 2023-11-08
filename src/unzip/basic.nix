{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "unzip" "basic"

{
  home.packages = [ pkgs.unzip ];
}
