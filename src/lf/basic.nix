{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "lf" "basic"

{
  home.programs.lf = {
    enable = true;
    keybindings = {
      "<delete>" = "delete";
    };
  };

  home.packages = [ pkgs.lf ];
}
