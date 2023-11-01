{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "yt-dlp" "basic"

{
  home.packages = [ pkgs.yt-dlp ];
}
