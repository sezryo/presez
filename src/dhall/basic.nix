{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "dhall" "basic"

{
  home.packages = [ pkgs.dhall ];
}
