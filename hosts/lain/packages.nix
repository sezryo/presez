{ config, pkgs, lib, inputs, ... }:

let
  inherit (lib.mine) rakeLeaves;
  modules = rakeLeaves ../../modules;
  systemFiles = with modules.system; [
    # Hardware optimisation
    flatpak chromium qemu supergfxd asusd acpica-tools

    # Gaming
    steam gamescope

    # Desktop environment
    hyprland xdotool wmctrl wayland
  ];

in {
  imports = systemFiles;
}
