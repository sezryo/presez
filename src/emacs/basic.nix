{ config, lib, pkgs, inputs, ... }:

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
  
