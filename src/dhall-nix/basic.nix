{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "dhall-nix" "basic"

{
  home.packages = [ pkgs.dhall-nix ];
}
