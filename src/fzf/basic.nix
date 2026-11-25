{ config, lib, pkgs, inputs, ... }:

{
  home.programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
}
