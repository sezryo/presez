{ config, lib, pkgs, ... }:

let
  # AMD 6800S
  gpuIDs = [
    "1002:73ef" # Graphics
    "1002:ab28" # Audio
  ];
  cfg = config.vfio;

in {
  options.vfio.enable = with lib;
    mkEnableOption "Configure the machine for VFIO";

  config = lib.mkIf cfg.enable
    {
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
      services.supergfxd.settings = lib.modules.importJSON ../../modules/supergfxd/vfio.conf;
    };
}
