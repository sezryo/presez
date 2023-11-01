{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "dhall-nix" "basic"

{
  home.packages = [ pkgs.dhall-nix ];
}
