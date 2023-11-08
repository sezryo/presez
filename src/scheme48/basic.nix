{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "scheme48" "basic"

{
  home.packages = [ pkgs.scheme48 ];
}
