{
  description = "The preimage of Sez";

  outputs = { self, nixpkgs, home-manager, nur, flake-parts, ... } @ inputs:

    let
      # Lib with extended customisations
      mkLib = nixpkgs:
        nixpkgs.lib.extend
          (self: super: { mine = import ./lib { lib = self; }; } // home-manager.lib);
      lib = mkLib inputs.nixpkgs;
      inherit (lib.mine) rakeLeaves;
      profiles = rakeLeaves ./profiles;

    in
      flake-parts.lib.mkFlake {
        inherit inputs;
        specialArgs = { inherit inputs lib; };
      } ({ self, lib, ... }:
      {
        imports = [
          profiles.configuration
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
    agenix.url = "github:ryantm/agenix";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    home-manager = { url = "github:nix-community/home-manager";
                     inputs.nixpkgs.follows = "nixpkgs"; };
    nur.url = "github:nix-community/NUR";
    flake-parts = { url = "github:hercules-ci/flake-parts";
                    inputs.nixpkgs-lib.follows = "nixpkgs"; };
    emacs-overlay = { url = "github:nix-community/emacs-overlay";
                      inputs.nixpkgs.follows = "nixpkgs"; };
    rust-overlay = { url = "github:oxalica/rust-overlay";
                     inputs.nixpkgs.follows = "nixpkgs"; };
    darkmatter-grub-theme = { url = "gitlab:VandalByte/darkmatter-grub-theme";
                              inputs.nixpkgs.follows = "nixpkgs"; };
    disko = { url = "github:nix-community/disko";
              inputs.nixpkgs.follows = "nixpkgs"; };
    claude-code = { url = "github:sadjow/claude-code-nix";
                    inputs.nixpkgs.follows = "nixpkgs"; };
    claude-desktop = { url = "github:patrickjaja/claude-desktop-bin";
                       inputs.nixpkgs.follows = "nixpkgs"; };
    claude-cowork = { url = "github:patrickjaja/claude-cowork-service";
                      inputs.nixpkgs.follows = "nixpkgs"; };
  };
}
