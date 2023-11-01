{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "steam" "basic"

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; 
    dedicatedServer.openFirewall = true;
  };
}
