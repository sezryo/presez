{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "ffmpeg" "basic"

{
  home.packages = [ pkgs.ffmpeg ];
}
