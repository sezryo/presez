{ config, lib, pkgs, ... }:

{
  environment.variables = rec {
    QT_QPA_PLATFORM = "wayland";
    # QT_STYLE_OVERRIDE = "qt5ct";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    NODE_OPTIONS = "--openssl-legacy-provider";
  };
}
