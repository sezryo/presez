{ pkgs, lib, ... }:

{
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    package = pkgs.callPackage ./myZoxide.nix {};
  };
}
