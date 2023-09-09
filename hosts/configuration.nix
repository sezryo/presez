{ self, inputs, lib, withSystem, ... }:

let
  inherit (inputs) home-manager hyprland darkmatter-grub-theme agenix disko;
  inherit (lib.mine) rakeLeaves;
  hosts = rakeLeaves ../hosts;
  hardwares = rakeLeaves ../hardwares;

  # Generate a minimum nixos system
  mkNixosConfig = {
    system ? "x86_64-linux",
    nixpkgs ? inputs.nixpkgs,
    latest ? inputs.latest,
    hardwareModules,      
    baseModules ? [
      home-manager.nixosModules.home-manager
      hosts.shared
      disko.nixosModules.disko
      agenix.nixosModules.default
    ],
    localeModules ? [],
    extraModules ? [],
  }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      modules = baseModules ++ hardwareModules ++ localeModules ++ extraModules;
      specialArgs = { inherit self inputs lib; };
    };
  
in {
  flake.nixosConfigurations = {
    "sezrienne" =
      withSystem "x86_64-linux"
      ({ pkgs, system, ...}:
        mkNixosConfig {
          hardwareModules = [ hardwares.ga402 ];
          extraModules = [
            hosts.sezrienne
            hyprland.nixosModules.default
            darkmatter-grub-theme.nixosModule
          ];
        });
    "lain" =
      withSystem "x86_64-linux"
      ({ pkgs, system, ...}:
        mkNixosConfig {
          hardwareModules = [ hardwares.ga402 ];
          extraModules = [
            hosts.lain
            hyprland.nixosModules.default
            darkmatter-grub-theme.nixosModule
          ];
        });
  };
}
