{ pkgs, lib, ... }:

{
  programs.lf = {
    enable = true;
    keybindings = {
      "<delete>" = "delete";
    };
  };

  home.packages = [ pkgs.lf ];
}
