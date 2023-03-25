{ pkgs, lib, ... }:

{
  gtk = {
    enable = true;
    font = {
      package = pkgs.jetbrains-mono;
      name = "JetBrains Mono";
    };

    # Anatognising gtk developers that they removed key-theme in gtk4
    gtk3.extraConfig = {
      "gtk-can-change-accels" = 1;
      "gtk-key-theme-name" = "Emacs";
    };
    gtk2.extraConfig = ''
      gtk-key-theme-name = "Emacs"
    '';

    theme = {
      name = "Catppuccin-Frappe";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "compact";
        tweaks = [ "rimless" "black" ];
        variant = "frappe";
      };
    };

    cursorTheme = {
      name = "Catppuccin-Frappe-Lavender-Cursors";
      package = pkgs.catppuccin-cursors.frappeLavender;
      size = 32;
    };

    iconTheme = {
      name = "Catppuccin-Frappe-Lavender-Cursors";
      package = pkgs.catppuccin-cursors.frappeLavender;
    };
  };
  home.packages = [ pkgs.gtk4 ];
}
