{ pkgs, lib, ... }:

{
  qt = {
    enable = true;
    style = "gtk2";
    platformTheme = "gtk2";
  };
  
  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtquickcontrols2
    libsForQt5.qt5.qtsvg
  ];
}
