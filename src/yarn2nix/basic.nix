{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "yarn2nix" "basic"

{
  home.packages = [ pkgs.yarn2nix ];
}
