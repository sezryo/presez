{ config, pkgs, lib, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = false;
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull ];
      };
      swtpm.enable = true;
    };
  };
  environment.systemPackages = with pkgs; [ virt-manager qemu swtpm ];
}
