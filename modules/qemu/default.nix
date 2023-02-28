{ pkgs, lib, ... }:

{
  virtualisation.libvirtd.qemu = {
    runAsRoot = false;
    ovmf = {
      enable = true;
      packages = [ pkgs.OVMFFull ];
    };
    swtpm.enable = true;
  };

  environment.systemPackages = [ pkgs.qemu ];
}
