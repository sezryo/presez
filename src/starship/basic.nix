{ config, lib, pkgs, inputs, ... }:

{
  home.programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
}
