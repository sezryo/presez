{ pkgs, lib, ... }:

{
  qt = {
    enable = true;
    # platformTheme = "qt5ct";
    style = {
      package = pkgs.libsForQt5.lightly;
      name = "lightly";
    };
  };
  
  home.file.".config/qt5ct/colors/Catppuccin-Frappe.conf".source = ./Catppuccin-Frappe.conf;
}
