{ config, lib, pkgs, inputs, ... }:

{
  home.configFile."alacritty/alacritty.toml".source = ./alacritty.toml;
}
