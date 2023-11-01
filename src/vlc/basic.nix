{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "vlc" "basic"

{
  home.packages = [ pkgs.vlc ];
}
