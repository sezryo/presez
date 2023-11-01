{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "qbittorrent" "basic"

{
  home.packages = [ pkgs.qbittorrent ];
}
