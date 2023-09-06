{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.qq ];
  xdg.desktopEntries.qq = {
    name = "QQ";
    genericName = "Mahuateng's Arschloch";
    exec = "qq --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto --enable-webrtc-pipewire-capture";
  };
}
