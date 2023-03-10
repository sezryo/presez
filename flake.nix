{
  description = "The preimage of Sez";

  outputs = inputs@{ self, nixpkgs, nur, hyprland, rust-overlay, emacs-overlay, nixos-hardware, home-manager, ...  }:
    let

      # These are modules used accross on system level
      nixos = { lib, ... }:
        {
          imports = [
            ./lists/systemList.nix
            ./system/configuration.nix
          ];
        };

      # These are common home settings across profiles
      common = { lib, config, ... }:
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          nixpkgs.overlays = [
            rust-overlay.overlays.default
            nur.overlay
            emacs-overlay.overlay
          ];
          _module.args = {
            colourscheme = import ./colourschemes/catppuccin-frappe.nix;
          };
        };

      # These are modules used on profile sezrienne
      sezrienne = { lib, ... }:
        {
          home-manager.users.sezrienne = {
            home.username = "sezrienne";
            home.homeDirectory = "/home/sezrienne";
            home.stateVersion = "22.05";
            imports = [ ./lists/sezrienneList.nix ];
          };
        };

      # Here is reserved for home-manager module blocks for other devices' environments

    in
    {
      nixosConfigurations.sezrienne = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          nixos
          common
          sezrienne
          hyprland.nixosModules.default
          home-manager.nixosModules.home-manager
        ];
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    hyprland.url = "github:hyprwm/Hyprland";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; };
    nur = {
      url = "github:nix-community/NUR"; };
    flake-utils.url = "github:numtide/flake-utils";
    emacs-overlay = { url = "github:nix-community/emacs-overlay";
                      inputs.nixpkgs.follows = "nixpkgs";
                      inputs.flake-utils.follows = "flake-utils"; };
    rust-overlay = { url = "github:oxalica/rust-overlay";
                     inputs.nixpkgs.follows = "nixpkgs";
                     inputs.flake-utils.follows = "flake-utils"; };
  };
}
