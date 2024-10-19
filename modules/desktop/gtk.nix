{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.desktop.gtk;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.desktop.gtk = {
    enable = mkEnableOpt "Enable GTK settings";
    enableDefault = mkEnableOpt "Enable Default GTK Theme settings";
    enableApps = mkEnableOpt "Enable GTK related packages";
    gnome = {
      enable = mkEnableOpt "Enable Gnome Wayland as DE";
      exclude = mkEnableOpt "Exclude Unnecessary Packages from Gnome";
    };
  };
  
  config = mkIf cfg.enable (mkMerge [
    {
      modules.singleton.gtk = [ "basic" ] ++ (if cfg.enableDefault then [ "catppuccin" "emacs" ] else []); 
    }
    (mkIf cfg.enableApps {
      modules.singleton = {
        gnome-control-center = [ "basic" ];
        gnome-tweaks = [ "basic" ];
        gnome-disks = [ "basic" ];
        networkmanagerapplet = [ "basic" ];
      };
    })
    (mkIf cfg.gnome.enable {
      modules.singleton = {
        gnome = [ "basic" ];
      };
      /* dconf.settings = {
        "org/gnome/mutter" = {
          experimental-features = [ "scale-monitor-framebuffer" ];
        }; 
      }; */
    })
    (mkIf cfg.gnome.exclude {
      modules.singleton.gnome = [ "exclude" ];
    })
  ]);
}
