{ pkgs, lib, ... }:

{
  home.pointerCursor = {
    package = pkgs.catppuccin-cursors.frappeLavender;
    name = "Catppuccin-Frappe-Lavender";
    size = 32;
    gtk.enable = true;
  };
}
