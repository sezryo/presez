{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "imagemagick" "basic"

{
  home.packages = [ pkgs.imagemagick ];
}
