{ config, lib, pkgs, inputs, ... }:

{
  home.programs.lf = {
    enable = true;
    keybindings = {
      "<delete>" = "delete";
    };
  };

  home.packages = [ pkgs.lf ];
}
