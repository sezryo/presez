{ self, inputs, lib, withSystem, ... }:

let
  inherit (lib) filterAttrs mapAttrs' nameValuePair concatMapAttrs isAttrs optional;
  inherit (lib.mine) rakeLeaves;

  profiles = rakeLeaves ./.;
  modules = rakeLeaves ../modules;

  # Base modules shared by every NixOS configuration.
  baseModules = [
    inputs.home-manager.nixosModules.home-manager
    inputs.disko.nixosModules.disko
    inputs.agenix.nixosModules.default
    inputs.hyprland.nixosModules.default
    inputs.darkmatter-grub-theme.nixosModule
    inputs.claude-cowork.nixosModules.default
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
    modules.termini
    modules.users
  ];

  # Generate a NixOS system from base modules and profile-specific modules.
  mkNixosConfig = {
    system ? "x86_64-linux",
    nixpkgs ? inputs.nixpkgs,
    profileModules ? [],
  }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      modules = baseModules ++ profileModules;
      specialArgs = { inherit self inputs lib; };
    };

  # Functionally discover all <user>/<machine> pairs under profiles/.
  # Each user directory may contain:
  #   - common.nix         (shared user config, optional)
  #   - <machine>/pinned.nix + hardware-configuration.nix
  #
  # Returns: { "<user>-<machine>" = <nixosConfiguration>; ... }
  discoverHosts = profileTree:
    let
      users = filterAttrs (_: v: isAttrs v) profileTree;
    in
      concatMapAttrs (userName: userAttrs:
        let
          machines = filterAttrs
            (n: v: n != "common" && isAttrs v)
            userAttrs;
        in
          mapAttrs' (machineName: machineAttrs:
            nameValuePair "${userName}-${machineName}" (
              withSystem "x86_64-linux" ({ ... }:
                mkNixosConfig {
                  profileModules =
                    optional (userAttrs ? common) userAttrs.common
                    ++ [
                      machineAttrs.hardware-configuration
                      machineAttrs.pinned
                    ];
                })
            )
          ) machines
      ) users;

in {
  flake.nixosConfigurations = discoverHosts profiles;
}
