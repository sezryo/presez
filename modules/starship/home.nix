{ pkgs, lib, ... }:

{
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = import ./myStarship.nix //
      builtins.fromTOML (builtins.readFile
      (pkgs.fetchFromGitHub
      {
        owner = "catppuccin";
        repo = "starship";
        rev = "5629d2356f62a9f2f8efad3ff37476c19969bd4f"; 
        sha256 = "nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
      } + /palettes/frappe.toml));
  };
}
