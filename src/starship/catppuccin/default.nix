{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "starship" "catppuccin"
{
  home.programs.starship = {
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
