{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "pnpm" "basic"

{
  home.packages = [ pkgs.nodePackages_latest.pnpm ];
}
