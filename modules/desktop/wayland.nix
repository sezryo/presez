{ config, pkgs, lib, inputs, options, ... }:

# Basic tools necessary for implementing any Wayland window manager (Hyprland, Sway, etc.)
let
  inherit (lib) mkIf mkMerge mkDefault;
  inherit (lib.types) enum;
  inherit (lib.mine) mkEnableOpt mkOpt';

  cfg = config.modules.desktop.wayland;
  wms = [ "hyprland" "sway" ];
  launchers = [ "fuzzel" "rofi" ];
  notifications = [ "dunst" ];
  screenshots = [ "grim" ];
  bars = [ "eww" "waybar" ];
in {
  options.modules.desktop.wayland = {
    enable = mkEnableOpt "Wayland support";
    minimum = mkEnableOpt "If enabled, only necessary wayland tools are installed, instead of a full window manager";
    wm = mkOpt' (enum wms) "hyprland" "Window manager to use";
    launcher = mkOpt' (enum launchers) "rofi" "Launcher to use";
    notification = mkOpt' (enum notifications) "dunst" "Notification manager to use";
    screenshot = mkOpt' (enum screenshots) "grim" "Screenshot manager to use";
    bar = mkOpt' (enum bars) "eww" "Bar to use";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.desktop.xserver.enable = mkDefault true;
      modules.singleton = {
        wayland = [ "basic" ];
        wl-clipboard = [ "basic" ];
        wlogout = [ "basic" ];
        wmctrl = [ "basic" ];
        wev = [ "basic" ];
        electron = [ "wayland" ];
      };
      environment.sessionVariables = {
        QT_QPA_PLATFORM = "wayland;xcb";
        SDL_VIDEODRIVER = "wayland";
      };
    }
    (mkIf (!cfg.minimum) {
      modules.singleton = {
        swaybg = [ "basic" ];
        ${cfg.wm} = [ "basic" ];
        ${cfg.launcher} = [ "basic" ];
        ${cfg.notification} = [ "basic" ];
        ${cfg.screenshot} = [ "basic" ];
        ${cfg.bar} = [ "basic" ];
      };
    })
  ]);
}
