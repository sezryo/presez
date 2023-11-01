{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "quickemu" "basic"

{
  home.packages = [ pkgs.quickemu ];
}
