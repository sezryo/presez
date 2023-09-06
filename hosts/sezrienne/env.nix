{ config, lib, pkgs, ... }:

{
  environment.sessionVariables = rec {
    XDG_CURRENT_DESKTOP = "Hyprland";
    QT_QPA_PLATFORM = "wayland";
    # QT_STYLE_OVERRIDE = "qt5ct";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    NODE_OPTIONS = "--openssl-legacy-provider";
    EDITOR = "emacsclient -c";
  };
}
