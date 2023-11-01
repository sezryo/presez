{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "quickgui" "basic"

{
  home.packages = [ pkgs.quickgui ];
}
