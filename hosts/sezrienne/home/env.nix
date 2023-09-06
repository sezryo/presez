{ pkgs, config, lib, ... }:

{
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };
}
