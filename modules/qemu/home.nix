{ pkgs, lib, ...}:

{
  home.packages = [ pkgs.qemu ];
  home.file.".config/libvirt/qemu.conf".text = lib.mkForce ''
    nvram = ["/run/libvirt/nix-ovmf/OVMF_CODE.fd:/run/libvirt/nix-ovmf/OVMF_VARS.fd"]
  '';
}
