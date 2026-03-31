{ config, pkgs, lib, inputs, options, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.mine) mkEnableOpt;

  cfg = config.modules.general.streaming;
in {
  options.modules.general.streaming = {
    enable = mkEnableOpt "Whether to enable streaming utilities";
  };

  config = mkIf cfg.enable {
    modules.singleton = {
      qbittorrent = [ "basic" ];
      spotify = [ "basic" ];
      ncspot = [ "basic" ];
      yewtube = [ "basic" ];
      yt-dlp = [ "basic" ];
      netflix = [ "basic" ];
      mixxx = [ "basic" ];
      vcv-rack = [ "basic" ];
    };
    networking.firewall.allowedTCPPorts = [ 57621 ]; # Spotify local discovery
  };
}
