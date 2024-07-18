{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "icalingua" "basic"

{
  home.packages = [ pkgs.nur.repos.linyinfeng.icalingua-plus-plus ];
}
