{ config, pkgs, lib, inputs, options, ... }:

# These are basic tools necessary for implementing any wayland window managers, e.g. sway and hyprland.
with lib;
with lib.types;

let
  cfg = config.modules.desktop.wayland;
  wms = [ "hyprland" "sway" ]; # TODO: Add a sway config
  launchers = [ "fuzzel" "rofi" ];
  notifications = [ "dunst" ];
  screenshots = [ "grim" ];
  bars = [ "eww" "waybar" ]; # TODO: Add a waybar config
  inherit (lib.mine) mkEnableOpt mkOpt mkOpt';
in {
  options.modules.desktop.wayland = {
    enable = mkEnableOpt "Wayland support";
    minimum = mkEnableOpt "If enabled, only necessary wayland tools are installed, instead of a well functional window manager";
    wm = mkOpt' (enum wms) "hyprland" "Window manager to use, currently sway is disabled";
    launcher = mkOpt' (enum launchers) "rofi" "Launcher to use";
    notification = mkOpt' (enum notifications) "dunst" "Notification manager to use";
    screenshot = mkOpt' (enum screenshots) "grim" "Screenshot manager to use";
    bar = mkOpt' (enum bars) "eww" "Bar to use";
  };
  
  config = mkIf cfg.enable (mkMerge [
    {
      modules.desktop.xserver = {
        enable = mkDefault true;
      };
      modules.singleton = {
        wayland = [ "basic" ];
        wl-clipboard = [ "basic" ];
        wlogout = [ "basic" ];
        wmctrl = [ "basic" ];
        wev = [ "basic" ];
        electron = [ "wayland" ];
      };
      environment.sessionVariables = rec {
        QT_QPA_PLATFORM = "wayland";
      };
    }
    (mkIf (!cfg.minimum) {
      modules.singleton = {
        swaybg = [ "basic" ];
        swaylock = [ "basic" ];
        ${cfg.wm} = [ "basic" ];
        ${cfg.launcher} = [ "basic" ];
        ${cfg.notification} = [ "basic" ];
        ${cfg.screenshot} = [ "basic" ];
        ${cfg.bar} = [ "basic" ];
      };
    })
  ]);
}
    
