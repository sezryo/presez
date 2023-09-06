{ pkgs, lib, ... }:

{
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    package = pkgs.zoxide; # pkgs.callPackage ./myZoxide.nix {};
  };
}
