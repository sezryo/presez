{ config, lib, pkgs, inputs, ... }:

{
  # This is an configuration that utilises wayland and suitable for dark-purple colourschemes
  home.programs.eww = {
    configDir = ./.;
  };
}
