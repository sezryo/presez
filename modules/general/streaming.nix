{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.general.streaming;
  inherit (lib.mine) mkEnableOpt mkOpt';
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
    };
    networking.firewall = {
      allowedTCPPorts = [ 57621 ]; # For Spotify local discovery
    };
  };
}
