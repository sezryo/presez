{ config, pkgs, lib, inputs, options, ... }:

# Ref. https://astrid.tech/2022/09/22/0/nixos-gpu-vfio/
# Shall not toggle on this module while not using vfio

with lib;
let
  gpuIDs = [
    "${config.gpu.graphics}"
    "${config.gpu.audio}"
  ];
  cfg = config.modules.hardware.vfio;
  inherit (lib.mine) mkEnableOpt;
in {
  options = {
    modules.hardware.vfio = {
      enable = mkEnableOpt "Configure the machine for VFIO";
    };
    runtime.vfio.enable = mkEnableOpt "Whether toggle vfio mode or not";
  };

  config = mkIf (cfg.enable && config.runtime.vfio.enable) {
    boot.kernelParams = [ "amd_iommu=on" ] ++ lib.optional cfg.enable
      # isolate the GPU
      ("vfio-pci.ids=" + lib.concatStringsSep "," gpuIDs);
    
    # These modules are required for PCI passthrough, and must come before early modesetting stuff
    boot.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];
    boot.extraModprobeConfig ="options vfio-pci ids=1002:73ef";
    
    boot.postBootCommands = ''
      echo "vfio-pci" > /sys/devices/pci0000:00/0000:00:01.1/0000:01:00.0/0000:02:00.0/0000:03:00.0/driver_override   
      modprobe -i vfio-pci
    '';           
  };
}
