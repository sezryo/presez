{ pkgs, lib, ... }:

{
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = import ./myStarship.nix;
  };
}
