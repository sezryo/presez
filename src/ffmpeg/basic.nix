{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ffmpeg" "basic"

{
  home.packages = [ pkgs.ffmpeg ];
}
