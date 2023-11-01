{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "calibre" "basic"

{
  home.packages = [ pkgs.calibre ];
}
