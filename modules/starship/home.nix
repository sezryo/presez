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
        rev = "3e3e54410c3189053f4da7a7043261361a1ed1bc"; 
        sha256 = "soEBVlq3ULeiZFAdQYMRFuswIIhI9bclIU8WXjxd7oY=";
      } + /palettes/frappe.toml));
  };
}
