{ config, lib, pkgs, inputs, ... }:

{
  home.programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    package = pkgs.zoxide; 
  };
}
