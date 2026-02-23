{ config, pkgs, lib, ... }:

lib.mine.mkIfProfile config.modules "zotero" "basic"

{
  home.packages = [ pkgs.zotero ];
}
