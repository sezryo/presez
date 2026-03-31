{ config, pkgs, lib, inputs, options, ... }:

# Hardware optimisation for ASUS ROG GA402 (G14 2022)
with lib;
let
  cfg = config.modules.hardware.x1nano2;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.hardware.x1nano2 = {
    enable = mkEnableOpt "Whether to enable Thinkpad X1 Nano Gen 2 hardware tools";
  };

  config = mkIf cfg.enable {

    hardware.ipu6 = {
      enable = true;
      platform = "ipu6ep";
    };

    # IPU6 Camera HAL needs /run/camera to write calibration data (aiqd files).
    # Without this, v4l2-relayd-ipu6 crash-loops and the camera drops randomly.
    systemd.tmpfiles.rules = [
      "d /run/camera 0755 root root -"
    ];

    # Increase restart tolerance so transient HAL failures don't permanently kill the camera
    systemd.services.v4l2-relayd-ipu6 = {
      serviceConfig = {
        RestartSec = 2;
        StartLimitBurst = 50;
        StartLimitIntervalSec = 120;
      };
    };

    services.fwupd.enable = true;

    # Intel thermal daemon — prevents thermal throttling by proactively managing thermals
    services.thermald.enable = true;
    
    gpu = {
      graphics = "8086:46a6";
      audio = "8086:51c8";
    };
    
    services.fprintd = {
      enable = true;
      tod.enable = true;
      tod.driver = pkgs.libfprint-2-tod1-goodix;
    };
    
    modules.hardware = {
      cpu = {
        enable = true; 
        intel = {
          enable = true;
        };
      };
      gpu = {
        enable = true;
        intel = {
          enable = true;
          driver = "xe";
        };
      };
      ssd.enable = true;
      power = {
        enable = true;
        tuning = true;
      };
    };
    
    # acpi_call
    boot = lib.mkIf config.services.tlp.enable {
      kernelModules = [ "acpi_call" ];
      extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
    };
  };
}
