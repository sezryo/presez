{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "qt" "basic"

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
  
  environment.systemPackages = with pkgs.libsForQt5; [
    qt5.qtgraphicaleffects
    qt5.qtquickcontrols2
    qt5.qtsvg
    qt5ct
  ];
}
