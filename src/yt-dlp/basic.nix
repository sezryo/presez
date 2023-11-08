{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "yt-dlp" "basic"

{
  home.packages = [ pkgs.yt-dlp ];
}
