{ config, lib, pkgs, inputs, ... }:

{
  home.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableNushellIntegration = true;
    enableBashIntegration = true;
  };
}
