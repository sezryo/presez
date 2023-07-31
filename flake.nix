{
  description = "The preimage of Sez";

  outputs = inputs@{ self, nixpkgs, nur, hyprland, rust-overlay, emacs-overlay, nixos-hardware, home-manager, darkmatter-grub-theme, ...  }:
    
    let

      # These are modules used accross on system level
      nixos = { lib, config, inputs, ... }:
        {
          imports = [
            ./lists/systemList.nix
            ./system/configuration.nix
          ];
        };

      # These are common home settings across profiles
      common = { lib, config, inputs, ... }:
        {
          imports = [
            ./homes/common/configuration.nix
          ];          
        };

      # These are sezrienne specific home settings
      sezrienne = { lib, config, inputs, ... }:
        {
          home-manager.users.sezrienne = {
            imports = [
              ./lists/sezrienneList.nix
              ./homes/sezrienne/configuration.nix
            ];
          };
        };

      # Here is reserved for home-manager module blocks for other devices' environments

    in
    {
      nixosConfigurations.sezrienne = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          nixos
          common
          sezrienne
          hyprland.nixosModules.default
          darkmatter-grub-theme.nixosModule
          home-manager.nixosModules.home-manager
        ];
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    latest.url = "github:nixos/nixpkgs/master";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    hyprland.url = "github:hyprwm/Hyprland";
    home-manager = { url = "github:nix-community/home-manager";
                     inputs.nixpkgs.follows = "nixpkgs"; };
    nur.url = "github:nix-community/NUR";
    flake-utils.url = "github:numtide/flake-utils";
    emacs-overlay = { url = "github:nix-community/emacs-overlay";
                      inputs.nixpkgs.follows = "nixpkgs";
                      inputs.flake-utils.follows = "flake-utils"; };
    rust-overlay = { url = "github:oxalica/rust-overlay";
                     inputs.nixpkgs.follows = "nixpkgs";
                     inputs.flake-utils.follows = "flake-utils"; };
    darkmatter-grub-theme = { url = "gitlab:VandalByte/darkmatter-grub-theme";
                              inputs.nixpkgs.follows = "nixpkgs"; };

  };
}
