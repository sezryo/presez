{ config, lib, pkgs, inputs, ... }:

{
  services.supergfxd = {
    enable = true;
  };
  
  environment.etc."supergfxd.conf" = {
    source = lib.mkDefault ./hybrid/hybrid.conf;
    mode = "0644";
  };
}
