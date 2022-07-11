{
  description = "The preimage of Sezrkatzen";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    sauricat.url = "github:sauricat/flakes";
    nur.url = "github:nix-community/NUR"; 
    emacs-overlay = { url = "github:nix-community/emacs-overlay";
                      inputs.nixpkgs.follows = "nixpkgs";
                      inputs.flake-utils.follows = "flake-utils"; };
    rust-overlay = { url = "github:oxalica/rust-overlay";
                     inputs.nixpkgs.follows = "nixpkgs";
                     inputs.flake-utils.follows = "flake-utils"; };
  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, home-manager, flake-utils, sauricat,  ... }:
  
    flake-utils.lib.eachDefaultSystem (system: {
      legacyPackages = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = builtins.attrValues self.overlays;
      };
    }) //

  {
    overlays = {
      forall = ( self: super:
        let
          dirContents = builtins.readDir ./potentia;
          genPackage = name: {
            inherit name;
            value = self.callPackage (./potentia + "/${name}") {}; };
          names = builtins.attrNames dirContents;
        in builtins.listToAttrs (map genPackage names)
      );
      nur = inputs.nur.overlay;
      emacs-overlay = inputs.emacs-overlay.overlay;
      rust-overlay = inputs.rust-overlay.overlay;
    };

    nixosModules.ego = { ... }: {
      nixpkgs.pkgs = self.legacyPackages."x86_64-linux";
      imports = [ ./fields ];
    };

    nixosConfigurations = {
      "sezrienne" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.inputs = inputs;
        modules = [
          ./sezrienne/subjectivity.nix
          { nixpkgs.pkgs = self.legacyPackages."x86_64-linux"; }
	  sauricat.nixosModules.smallcat
          self.nixosModules.ego
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.sezrienne = import ./le-symbolique/signifiers.nix;
          }
        ];
      }; 
    };
  };
}
