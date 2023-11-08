{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "vlc" "basic"

{
  home.packages = [ pkgs.vlc ];
}
