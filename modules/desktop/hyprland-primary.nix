{ config, pkgs, lib, inputs, options, ... }:

# These are the current primary desktop setting for me using hyprland
with lib;
with lib.types;
let
  cfg = config.modules.desktop.hyprland-primary;
  versions = [ "osaka" "tokyo" ];
  inherit (lib.mine) mkEnableOpt mkOpt';
in {
  options.modules.desktop.hyprland-primary = {
    enable = mkEnableOpt "Primary Hyprland Setup";
    version = mkOpt' (enum versions) "osaka" "Which version to use";
  };
  
  config = mkIf cfg.enable (mkMerge [
   {
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
        # swaylock = [ "effects" ];
        rofi = [ "deathemonic" ];
      };
    };
    services.xserver.dpi = 160;
    environment.sessionVariables = rec {
      XDG_CURRENT_DESKTOP = "Hyprland";
    };
  }
  (mkIf (cfg.version == "osaka") {
     modules.singleton.hyprland = [ "osaka-night" ];
  })
  (mkIf (cfg.version == "tokyo") {
     modules.singleton.hyprland = [ "tokto-night" ];
  })
  ]);
}
    
