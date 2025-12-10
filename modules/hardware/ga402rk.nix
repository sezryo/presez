{ config, pkgs, lib, inputs, options, ... }:

# Hardware optimisation for ASUS ROG GA402 (G14 2022)
with lib;
let
  cfg = config.modules.hardware.ga402rk;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.hardware.ga402rk = {
    enable = mkEnableOpt "Whether to enable ASUS ROG GA402 (G14 2022) hardware tools";
  };

  config = mkIf cfg.enable {
    gpu = {
      graphics = "1002:73ef";
      audio = "1002:ab28";
    };
    
    modules.hardware = {
      cpu = {
        enable = true;
        # autofreq = true; # Tuning of GA402 is terrible
        amd = {
          enable = true;
          pstate = true;
        };
      };
      gpu = {
        enable = true;
        amd = {
          enable = true;
          loadInInitrd = true;
          opencl = true;
        };
      };
      ssd.enable = true;
      power = {
        enable = true;
        tuning = true;
      };
    };
    modules.singleton = {
      asusd = [ "basic" "defaultSettings" ];
      supergfxd = [ "basic" "hybrid" "integrated" "vfio" ];
    };
    
    # fixes mic mute button
    services.udev.extraHwdb = ''
      evdev:name:*:dmi:bvn*:bvr*:bd*:svnASUS*:pn*:*
       KEYBOARD_KEY_ff31007c=f20
    '';
  };
}
