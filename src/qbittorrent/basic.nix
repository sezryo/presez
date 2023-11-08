{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "qbittorrent" "basic"

{
  home.packages = [ pkgs.qbittorrent ];
}
