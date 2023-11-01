{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "supergfxd" "basic"

{
  services.supergfxd = {
    enable = true;
  };
  
  environment.etc."supergfxd.conf" = {
    source = lib.mkDefault ./hybrid/hybrid.conf;
    mode = "0644";
  };
}
