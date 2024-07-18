{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "goldendict-ng" "basic"

{
  home.packages = [ pkgs.goldendict-ng ];
}
