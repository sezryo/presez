{ config, pkgs, lib, inputs, options, ... }:

with lib;
let
  cfg = config.modules.io.virtualisation;
  inherit (lib.mine) mkEnableOpt;
in {
  options.modules.io.virtualisation = {
    enable = mkEnableOpt "Whether to enable essential libvirtd settings";
    qemu = mkEnableOpt "Whether to enable qemu as virtualiser";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      virtualisation.libvirtd = {
        enable = true;
        allowedBridges = [
          "nm-bridge"
          "virbr0"
        ];
      };
      users.users.${config.user.name}.extraGroups = [ "libvirtd" ];
      virtualisation.spiceUSBRedirection.enable = true;
      modules.singleton = {
        swtpm = [ "basic" ];
        spice = [ "basic" "gtk" "protocol" "vdagentd" "win" ];
        win-virtio = [ "basic" ];
      };
    }
    (mkIf cfg.qemu {
      modules.singleton = {
        qemu = [ "basic" ];
        virt-manager = [ "basic" ];
        quickemu = [ "basic" ];
        # quickgui = [ "basic" ];
      };
    })
  ]);
}
