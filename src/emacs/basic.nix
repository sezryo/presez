{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "emacs" "basic"

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
  
