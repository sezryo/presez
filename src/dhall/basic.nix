{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "dhall" "basic"

{
  home.packages = [ pkgs.dhall ];
}
