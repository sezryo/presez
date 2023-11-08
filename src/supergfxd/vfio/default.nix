{ config, lib, pkgs, inputs, ... }:

with lib;
lib.mine.mkIfProfile config.modules "supergfxd" "vfio" {
  environment.etc."supergfxd.conf" = mkIf config.runtime.vfio.enable {
    source = ./vfio.conf;
    mode = "0644";
  };

  specialisation."VFIO".configuration = {
    system.nixos.tags = [ "with-vfio" ];
    runtime.vfio.enable = true;
  };
}
