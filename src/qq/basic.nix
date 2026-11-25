{ config, lib, pkgs, inputs, ... }:

{
  home.packages = [ pkgs.qq ];
  home.desktopEntries.qq = {
    name = "QQ-wayland";
    genericName = "Mahuateng's Arschloch";
    exec = "qq --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto --enable-webrtc-pipewire-capture";
  };
}
