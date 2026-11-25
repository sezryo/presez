{ config, lib, pkgs, inputs, ... }:

{
  
  environment.systemPackages = [ pkgs.firefox ];
  
  home.programs.firefox = {
    enable = true;
    configPath = ".mozilla/firefox";
  };
}
