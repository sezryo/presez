{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "qt" "catppuccin"
{
  home.qt = {
    style = {
      package = pkgs.libsForQt5.lightly;
      name = "lightly";
    };
  };
  
  environment.systemPackages = with pkgs.libsForQt5; [
    lightly
  ];
  
  home.configFile."qt5ct/colors/Catppuccin-Frappe.conf".source = ./myQt.conf;
}
