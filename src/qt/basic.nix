{ config, lib, pkgs, inputs, ... }:

{
  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };
  
  home.qt = {
    enable = true;
    platformTheme.name = "qtct";
  };
 
  environment.sessionVariables = rec {
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };
  
  environment.systemPackages = with pkgs; [
    qt5.qtgraphicaleffects
    qt5.qtquickcontrols2
    qt5.qtsvg
    libsForQt5.qt5ct
  ];
}
