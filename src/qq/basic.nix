{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "qq" "basic"

{
  home.packages = [ pkgs.qq ];
  home.desktopEntries.qq = {
    name = "QQ-wayland";
    genericName = "Mahuateng's Arschloch";
    exec = "qq --enable-features=WaylandWindowDecorations --ozone-platform-hint=auto --enable-webrtc-pipewire-capture";
  };
}
