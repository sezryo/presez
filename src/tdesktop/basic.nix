{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "tdesktop" "basic"

{
  home.packages = [ pkgs.tdesktop ];
}
