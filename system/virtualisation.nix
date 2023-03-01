{ pkgs, lib, config, ... }:{

  virtualisation.libvirtd = {
    enable = true;
    allowedBridges = [
      "nm-bridge"
      "virbr0"
    ];
  # Configurations about QEMU shall be found in modules/qemu
  };
  virtualisation.spiceUSBRedirection.enable = true;

  environment.systemPackages = with pkgs; [
    swtpm
    spice spice-gtk spice-protocol
    win-virtio win-spice
  ];
  services.spice-vdagentd.enable = true;

  users.groups.libvirtd.members = [ "root" "sezrienne" ];
}
