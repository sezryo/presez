{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.hardware.cpu;
  inherit (lib.mine) mkEnableOpt mkEnableOptIf mkOpt mkOpt';
  kver = config.boot.kernelPackages.kernel.version;
in {
  options.modules.hardware.cpu = {
    enable = mkEnableOpt "Whether to enable cpu related services";
    autofreq = mkEnableOpt "Use default settings for cpu-autofreq";
    amd = {
      enable = mkEnableOpt "Whether to enable APU related services";
      pstate = mkEnableOpt "Whether to enable AMD pstate packages";
    };
    intel = {
      enable = mkEnableOpt "Whether to enable Intel CPU related services";
      # TODO: Finish intel settings
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.autofreq {
      modules.singleton = {
        auto-cpufreq = [ "basic" ];
        cpufrequtils = [ "basic" ];
      };
    })
    (mkIf cfg.amd.enable {
      hardware.cpu.amd.updateMicrocode =
        lib.mkDefault config.hardware.enableRedistributableFirmware;
    })
    (mkIf cfg.amd.pstate {
      # Enables the amd cpu scaling https://www.kernel.org/doc/html/latest/admin-guide/pm/amd-pstate.html
      # On recent AMD CPUs this can be more energy efficient.
      boot = mkMerge [
        (mkIf( (versionAtLeast kver "5.17") && (versionOlder kver "6.1") ){
          kernelParams = [ "initcall_blacklist=acpi_cpufreq_init" ];
          kernelModules = [ "amd-pstate" ];
        })
        (mkIf( (lib.versionAtLeast kver "6.1") && (versionOlder kver "6.3") ){
          kernelParams = [ "amd_pstate=passive" ];
        })
        (mkIf (lib.versionAtLeast kver "6.3") {
          kernelParams = [ "amd_pstate=active" ];
        })
      ];
    })
  ]);
}
