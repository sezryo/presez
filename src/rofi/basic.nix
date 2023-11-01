{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "rofi" "basic"

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
