{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "grex" "basic"

{
  home.packages = [ pkgs.grex ];
}
