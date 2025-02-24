{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "gtk" "catppuccin"

{
  home.gtk = {
    
    font = {
      package = pkgs.jetbrains-mono;
      name = "JetBrains Mono";
    };

    theme = {
      name = "catppuccin-frappe";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "compact";
        tweaks = [ "rimless" "black" ];
        variant = "frappe";
      };
    };

    cursorTheme = {
      name = "catppuccin-frappe-lavender-cursors";
      package = pkgs.catppuccin-cursors.frappeLavender;
      size = 32;
    };

    iconTheme = {
      name = "catppuccin-frappe-lavender-cursors";
      package = pkgs.catppuccin-cursors.frappeLavender;
    };
  };
}
