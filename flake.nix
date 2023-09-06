{
  description = "The preimage of Sez";

  outputs = {
    self, nixpkgs, latest, nur, hyprland, rust-overlay, emacs-overlay, home-manager, darkmatter-grub-theme, agenix, flake-parts, ...  } @ inputs:
    
    let
      # Lib with extended customisations
      mkLib = nixpkgs:
        nixpkgs.lib.extend
          (self: super: {mine = import ./lib {lib = self;};} // home-manager.lib);
      lib = mkLib inputs.nixpkgs; 
      inherit (lib.mine) rakeLeaves;

      hosts = rakeLeaves ./hosts;

    in
      flake-parts.lib.mkFlake {
        inherit inputs;
        specialArgs = { inherit lib; };
      } ({ self, lib, ... }:
      {
        # Imports flake-parts modules
        imports = [
          hosts.configuration
          flake-parts.flakeModules.easyOverlay
        ];

        systems = [
          "aarch64-linux"
          "x86_64-linux"
        ];

        perSystem = { inputs', self', pkgs, ... }: {
          _module.args = {
            pkgs = inputs'.nixpkgs.legacyPackages;
            lib = lib;
          };
        };
      });    

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    latest.url = "github:nixos/nixpkgs/master";
    agenix.url = "github:ryantm/agenix";
    hyprland.url = "github:hyprwm/Hyprland";
    home-manager = { url = "github:nix-community/home-manager";
                     inputs.nixpkgs.follows = "nixpkgs"; };
    nur.url = "github:nix-community/NUR";
    flake-parts = { url = "github:hercules-ci/flake-parts";
                    inputs.nixpkgs-lib.follows = "nixpkgs"; };
    emacs-overlay = { url = "github:nix-community/emacs-overlay";
                      inputs.nixpkgs.follows = "nixpkgs";};
    rust-overlay = { url = "github:oxalica/rust-overlay";
                     inputs.nixpkgs.follows = "nixpkgs";};
    darkmatter-grub-theme = { url = "gitlab:VandalByte/darkmatter-grub-theme";
                              inputs.nixpkgs.follows = "nixpkgs"; };

  };
}
