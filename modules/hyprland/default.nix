{ pkgs, inputs, config, lib, ... }:

{
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
    xwayland.hidpi = true;
    nvidiaPatches = false; # Currently use AMD dedicated GPU
  };
}
