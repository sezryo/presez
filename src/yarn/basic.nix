{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "yarn" "basic"

{
  home.packages = [ pkgs.yarn ];
}
