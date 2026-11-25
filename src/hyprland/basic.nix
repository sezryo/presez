{ config, lib, pkgs, inputs, ... }:

let
  # Hyprland's flake gave up its own NixOS module on 2026-11-25 (importing it
  # is now a failed assertion). The module in nixpkgs does the same work; only
  # the packages still come from the flake, as they did through that module.
  hyprland = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  programs.hyprland = {
    enable = true;
    package = hyprland.hyprland;
    portalPackage = hyprland.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
    # xwayland.hidpi = true; # Deprecated
  };
}
