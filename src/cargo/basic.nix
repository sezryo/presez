{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "cargo" "basic"

{
  home.packages = [ pkgs.cargo ];
}
