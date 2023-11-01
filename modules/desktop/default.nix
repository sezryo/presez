{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./cursor.nix
    ./display.nix
    ./gtk.nix
    ./hyprland-primary.nix
    ./qt.nix
    ./wayland.nix
    ./xserver.nix
  ];
}
