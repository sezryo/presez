{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.desktop.xserver;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.desktop.xserver = {
    enable = mkEnableOpt "Necessary xserver fundamentals";
    touchpad = {
      enable = mkEnableOpt "Enable default libinput configuration";
      wacom = mkEnableOpt "Enable wacom related services";
    };
    wm = {
      enable = mkEnableOpt "Enable this if you want to use standalone x11 window manager";
      minimum = mkEnableOpt "Enable this if you only want necessary x11 wm tools, useful while using wayland but need some x11 tools";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.xserver = {
        enable = true;
        exportConfiguration = true;
      };
      xdg.portal = {
        enable = true;
        # config.common.default = "*";
      };
    }
    (mkIf cfg.touchpad.enable {
      services.libinput = {
        enable = true;
        touchpad = {
          tapping = true;
          scrollMethod = "twofinger";
          naturalScrolling = true;
          middleEmulation = true;
        };
      };
      modules.singleton.libinput-gestures = [ "basic" ];
    })
    (mkIf cfg.touchpad.wacom {
      services.xserver.wacom.enable = true;
      modules.singleton.opentabletdriver = [ "basic" ];
    })
    (mkIf (cfg.wm.enable && cfg.wm.minimum) {
      modules.singleton = {
        xdotool = [ "basic" ];
      };
    })
  ]);
}
