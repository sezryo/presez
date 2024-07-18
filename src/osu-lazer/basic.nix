{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "osu-lazer" "basic"

{
  home.packages = [ pkgs.osu-lazer-bin ];
}
