{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "pnpm" "basic"

{
  home.packages = [ pkgs.nodePackages_latest.pnpm ];
}
