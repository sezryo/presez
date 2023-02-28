{ config, pkgs, lib, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [
      "nm-bridge"
      "virbr0"
    ];

    # Configurations about QEMU shall be found in modules/qemu
  };
  environment.systemPackages = with pkgs; [
    swtpm
    spice spice-gtk spice-protocol
    win-virtio win-spice
  ];
}
