{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "calibre" "basic"

{
  home.packages = [ pkgs.calibre ];
}
