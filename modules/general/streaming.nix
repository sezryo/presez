{
  description = "music, video and streaming applications";
  packages = [
    "qbittorrent"
    "spotify"
    "ncspot"
    "yewtube"
    "yt-dlp"
    "netflix"
    "mixxx"
    "vcv-rack"
  ];
  config = {
    networking.firewall.allowedTCPPorts = [ 57621 ]; # Spotify local discovery
  };
}
