{ config, lib, pkgs, inputs, ... }:

with lib;
lib.mine.mkIfProfile config.modules "supergfxd" "hybrid" {
  environment.etc."supergfxd.conf" = mkIf config.runtime.hybrid.enable {
    source = ./hybrid.conf;
    mode = "0644";
  };
  
  specialisation."HYBRID".configuration = {
    system.nixos.tags = [ "hybrid-gpu" ];
    runtime.hybrid.enable = true;
  };
}
