{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "tdesktop" "basic"

{
  home.packages = [ pkgs.tdesktop ];
}
