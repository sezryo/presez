{ self, inputs, lib, withSystem, ... }:

let
  inherit (lib.mine) rakeLeaves;
  profiles = rakeLeaves ./.;
  modules = rakeLeaves ../modules;

  # Generate a minimum nixos system
  mkNixosConfig = {
    system ? "x86_64-linux",
    nixpkgs ? inputs.nixpkgs,
    latest ? inputs.latest,     
    baseModules ? [
      inputs.home-manager.nixosModules.home-manager
      inputs.disko.nixosModules.disko
      inputs.agenix.nixosModules.default
      modules.boot
      modules.desktop
      modules.dev
      modules.general
      modules.hardware
      modules.io
      modules.locale
      modules.network
      modules.nix
      modules.security
      modules.shell
      modules.singleton
      modules.users
    ],
    profiles ? [],
  }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      modules = baseModules ++ profiles;
      specialArgs = { inherit self inputs lib;}; 
    };
in {
  flake.nixosConfigurations = {
    "sezrienne" =
      withSystem "x86_64-linux"
      ({ pkgs, system, ...}:
        mkNixosConfig {
          profiles = [
            profiles.sezrienne.pinned
            profiles.sezrienne.hardware-configuration
            inputs.hyprland.nixosModules.default
            inputs.darkmatter-grub-theme.nixosModule
          ];
        });
    "lain" =
      withSystem "x86_64-linux"
      ({ pkgs, system, ...}:
        mkNixosConfig {
          profiles = [
            inputs.hyprland.nixosModules.default
            inputs.darkmatter-grub-theme.nixosModule
          ];
        });
  };
}
