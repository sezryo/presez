{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "hyprland" "basic"

{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
    # xwayland.hidpi = true; # Deprecated
  };
}
