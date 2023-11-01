{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "agda" "basic"

{
  home.packages = [ pkgs.agda ];
}
