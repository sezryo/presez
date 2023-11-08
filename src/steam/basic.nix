{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "steam" "basic"

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; 
    dedicatedServer.openFirewall = true;
  };
}
