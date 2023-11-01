{ config, pkgs, lib, inputs, options, ... }:

# These are the current primary desktop setting for me using hyprland
with lib;
let
  cfg = config.modules.desktop.hyprland-primary;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.desktop.hyprland-primary = {
    enable = mkEnableOpt "Primary Hyprland Setup";
  };
  
  config = mkIf cfg.enable {
    modules = {
      desktop = {
        wayland = {
          enable = mkDefault true;
          wm = "hyprland";
          launcher = "rofi";
          notification = "dunst";
          screenshot = "grim";
          bar = "eww";
        };
        xserver = {
          enable = true;
        };
      };
      singleton = {
        eww = [ "iceberg" ];
        swaylock = [ "effects" ];
        rofi = [ "deathemonic" ];
        hyprland = [ "tokyo-night" ];
      };
    };
    services.xserver.dpi = 160;
    environment.sessionVariables = rec {
      XDG_CURRENT_DESKTOP = "Hyprland";
    };
  };
}
    
