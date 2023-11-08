{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "yarn2nix" "basic"

{
  home.packages = [ pkgs.yarn2nix ];
}
