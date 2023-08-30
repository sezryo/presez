{ pkgs, lib, config, inputs, ... }:

{
  imports =
    [
      ./env.nix
      ./cursor.nix
    ];

  home.username = "sezrienne";
  home.homeDirectory = "/home/sezrienne";
  home.stateVersion = "22.05";
  systemd.user.startServices = "sd-switch"; # Enforce to start user-level services after booting
}
