{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "grex" "basic"

{
  home.packages = [ pkgs.grex ];
}
