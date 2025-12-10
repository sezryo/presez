{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "qemu" "basic"

{
  virtualisation.libvirtd.qemu = {
    runAsRoot = false;
    /* ovmf = {
      enable = true;
      packages = [ pkgs.OVMFFull.fd ];
    }; */ # Enabled by default
    swtpm.enable = true;
  };

  environment.systemPackages = [ pkgs.qemu ];
  
  home.configFile."libvirt/qemu.conf".text = lib.mkForce ''
    nvram = ["/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd"]
  '';
}
