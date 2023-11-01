{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.hardware.gpu;
  inherit (lib.mine) mkEnableOpt mkEnableOptIf mkOpt mkOpt' mkOptStr;
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
        enable = mkEnableOpt "Whether to enable Nvidia GPU related packages";
        # TODO: Finish nvidia settings
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
        opengl = [ "basic" ];
        mesa = [ "basic" ];
        mesa-demos = [ "basic" ];
      };
    }
    (mkIf cfg.amd.enable {
      modules.singleton = {
        radeontop = [ "basic" ];
      };
      services.xserver.videoDrivers = lib.mkDefault [ "modesetting" ];
      gpu.type = "amd";
    })
    (mkIf cfg.amd.loadInInitrd {
      boot.initrd.kernelModules = [ "amdgpu" ];
    })
    (mkIf cfg.amd.amdvlk {
      modules.singleton = {
        opengl = [ "amdvlk" ];
      };
    })
    (mkIf cfg.amd.opencl {
      modules.singleton = {
        opengl = [ "opencl" ];
      };
    })
  ]);
}
