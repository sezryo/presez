{ config, pkgs, lib, inputs, options, ... }:

with lib;
with lib.types;
let
  cfg = config.modules.hardware.gpu;
  inherit (lib.mine) mkEnableOpt mkEnableOptIf mkOpt mkOpt' mkOptStr;
  intel_drivers = [ "i915" "xe" ];
in {
  options = {
    modules.hardware.gpu = {
      enable = mkEnableOpt "Whether to enable graphic related services";
      amd = {
        enable = mkEnableOpt "Whether to enable AMD GPU related packages";
        loadInInitrd = mkEnableOptIf "Load AMD Module at stage 1" (cfg.amd.enable);
        amdvlk = mkEnableOpt "Use amdvlk drivers instead mesa radv drivers";
        opencl = mkEnableOptIf "Rocm opencl runtime (Install rocm-opencl-icd and rocm-opencl-runtime)" (cfg.amd.enable);
      };
      nvidia = {
        enable = mkEnableOpt "Whether to enable Nvidia GPU related settings";
        # TODO: Finish nvidia settings
      };
      intel = {
        enable = mkEnableOpt "Whether to enable Intel integrated GPU related settings";
        driver = mkOpt' (enum intel_drivers) "i915" "Which intel driver to be used";
      };
    };
    gpu = {
      type = mkOptStr null;
      audio = mkOptStr null; # GPU ID of audio
      graphics = mkOptStr null; # GPU ID of graphics
    };
    runtime = {
      hybrid.enable = mkEnableOpt "Hybrid GPU scheme";
      integrated.enable = mkEnableOpt "Integrated GPU scheme";
      dedicated.enable = mkEnableOpt "Dedicated GPU scheme";
    };
        
  };

  config = mkIf cfg.enable (mkMerge [
    {
      modules.singleton = { 
        mesa = [ "basic" ];
        mesa-demos = [ "basic" ];
      };
      hardware.graphics.enable = true;
    }
    (mkIf cfg.amd.enable {
      modules.singleton = {
        radeontop = [ "basic" ];
      };
      services.xserver.videoDrivers = [ "modesetting" ];
      gpu.type = "amd";
    })
    (mkIf cfg.amd.loadInInitrd {
      boot.initrd.kernelModules = [ "amdgpu" ];
    })
    (mkIf cfg.amd.amdvlk {
      hardware.graphics = {
        extraPackages = with pkgs; [
          amdvlk
        ];

        extraPackages32 = with pkgs; [
          driversi686Linux.amdvlk
        ];
      };
    })
    (mkIf cfg.amd.opencl {
      hardware.graphics = {
        extraPackages = with pkgs; [
          rocmPackages.clr.icd
        ];
      };
    })
    (mkIf cfg.intel.enable {
      boot.initrd.kernelModules = [ cfg.intel.driver ];
      environment.variables = {
        VDPAU_DRIVER = lib.mkIf config.hardware.graphics.enable (lib.mkDefault "va_gl");
      };
      hardware.graphics.extraPackages = with pkgs; [
        (
          if (lib.versionOlder (lib.versions.majorMinor lib.version) "23.11") then
            vaapiIntel
          else
            intel-vaapi-driver
        )
        intel-media-driver
      ];
      
      hardware.graphics.extraPackages32 = with pkgs.driversi686Linux; [
        (
          if (lib.versionOlder (lib.versions.majorMinor lib.version) "23.11") then
            vaapiIntel
          else
            intel-vaapi-driver
        )
        intel-media-driver
      ];
    })
  ]);
}
