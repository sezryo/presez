{
  description = "The preimage of Sezrkatzen";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    hyprland.url = "github:hyprwm/Hyprland";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs"; };
    flake-utils.url = "github:numtide/flake-utils";
    emacs-overlay = { url = "github:nix-community/emacs-overlay";
                      inputs.nixpkgs.follows = "nixpkgs";
                      inputs.flake-utils.follows = "flake-utils"; };
    rust-overlay = { url = "github:oxalica/rust-overlay";
                     inputs.nixpkgs.follows = "nixpkgs";
                     inputs.flake-utils.follows = "flake-utils"; };
  };

  outputs = inputs@{ self, nixpkgs, nur, hyprland, rust-overlay, nixos-hardware, home-manager, ...  }:
    let

      # These are modules used accross all devices on system level
      systemCommon = { lib, ... }:
        {
          imports = [ ./lists/systemCommonList.nix ];
        };

      # These are modules used accross all devices on home level
      homeCommon = { lib, ... }:
        {
          # _module.args = {
          #   colourscheme = import ./colourscheme/tokyonight.nix;
          # };
          nixpkgs.config.allowUnfreePredicate = (pkg: true);
          nixpkgs.overlays = [
            rust-overlay.overlays.default
          ];
          programs.home-manager.enable = true;
          home.stateVersion = "22.05";
          imports = [ ./lists/homeCommonList.nix ];
        };

      # These are modules used on Init on system level. Init is sez-code for sez's ga402
      homeInit = { lib, ... }:
        {
          nixpkgs.config.allowUnfreePredicate = (pkg: true);
          home.homeDirectory = "/home/sezrienne";
          home.username = "sezrienne";
          imports = [ ./lists/homeInitList.nix ];
      };

      # Here is resrved for home-manager module blocks for other devices' environments

    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nur.nixosModules.nur
          systemCommon
          ./system/configuration.nix
        ];
      };

      homeConfigurations.nixos = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          hyprland.homeManagerModules.default
          homeCommon
          homeInit
        ];
      };
    };

}
