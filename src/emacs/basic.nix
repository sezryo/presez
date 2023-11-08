{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "emacs" "basic"

{
  home = {
    services.emacs = {
      enable = true; 
    };
    programs.emacs = {
      enable = true;
    };
  };
}
  
