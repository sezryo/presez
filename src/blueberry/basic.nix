{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "blueberry" "basic"

{
  home.packages = [ pkgs.blueberry ];
}
