{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gtk" "emacs"

{
  home.gtk = {

    # Anatognising gtk developers that they removed emacs key-theme in gtk4
    gtk3.extraConfig = {
      "gtk-can-change-accels" = 1;
      "gtk-key-theme-name" = "Emacs";
    };
    gtk2.extraConfig = ''
      gtk-key-theme-name = "Emacs"
    '';
  };
}
