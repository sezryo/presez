{ pkgs, lib, ... }:

{
  # Still, cannot change the mode between integrated and hybrid
  services.supergfxd = {
    enable = true;

    # This does not work, probably due to priority reason, need PR
    # settings = lib.mkDefault (lib.modules.importJSON ./non-specialised.conf);
  };
  environment.etc."supergfxd.conf" = {
    source = lib.mkDefault ./non-specialised.conf;
    mode = "0644";
  };
}
