{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "eww" "iceberg"
{
  # This is an configuration that utilises wayland and suitable for dark-purple colourschemes
  home.programs.eww = {
    configDir = ./.;
  };
}
