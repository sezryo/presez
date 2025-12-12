{
  description = "The preimage of Sez";

  outputs = { self, nixpkgs, home-manager, nur, flake-parts, devshell, mission-control, treefmt-nix, ...  } @ inputs:
    
    let
      # Lib with extended customisations
      mkLib = nixpkgs:
        nixpkgs.lib.extend
          (self: super: {mine = import ./lib {lib = self;};} // home-manager.lib);
      lib = mkLib inputs.nixpkgs; 
      inherit (lib.mine) rakeLeaves;
      profiles = rakeLeaves ./profiles;

    in
      flake-parts.lib.mkFlake {
        inherit inputs;
        specialArgs = { inherit inputs lib; };
      } ({ self, lib, ... }:
      {
        # Imports flake-parts modules
        imports = [
          profiles.configuration
          flake-parts.flakeModules.easyOverlay
          devshell.flakeModule
          mission-control.flakeModule
          # nur.repos.linyinfeng.lpac # TODO: Need to sort out the correct way installing nur packages.
          # treefmt-nix.flakeModule
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
    devshell = { url = "github:numtide/devshell";
                 inputs.nixpkgs.follows = "nixpkgs"; };
    treefmt-nix.url = "github:numtide/treefmt-nix";
    mission-control.url = "github:Platonic-Systems/mission-control";

  };
}
