{ config, lib, pkgs, inputs, ... }:

{
  home.programs.rofi = {
    enable = true;
    package = if config.modules.desktop.wayland.enable
              then pkgs.rofi-wayland
              else pkgs.rofi;
    terminal = if (config.modules.singleton.wezterm != null)
               then "wezterm"
               else null;
  };
}
