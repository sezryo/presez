{ pkgs, lib, ... }:

{
  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };

  # QT related environment variables set in ~/system/env.nix
  
  environment.systemPackages = with pkgs.libsForQt5; [
    qt5.qtgraphicaleffects
    qt5.qtquickcontrols2
    qt5.qtsvg
    qt5ct
    lightly
  ];
}
