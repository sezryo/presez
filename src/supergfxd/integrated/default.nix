{ config, lib, pkgs, inputs, ... }:

with lib;
lib.mine.mkIfProfile config.modules "supergfxd" "integrated" {
  environment.etc."supergfxd.conf" = mkIf config.runtime.integrated.enable {
    source = ./integrated.conf;
    mode = "0644";
  };
  
  specialisation."INTEGRATED".configuration = {
    system.nixos.tags = [ "low-energy" ];
    runtime.integrated.enable = true;
  };
}
