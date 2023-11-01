{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "xvidcore" "basic"

{
  home.packages = [ pkgs.xvidcore ];
}
