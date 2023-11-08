{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "imagemagick" "basic"

{
  home.packages = [ pkgs.imagemagick ];
}
