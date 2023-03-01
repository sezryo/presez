{ pkgs, lib, ... }:

{
  # Still, cannot change the mode between integrated and hybrid
  services.supergfxd = {
    enable = true;
    settings = lib.mkDefault (lib.modules.importJSON ./non-specialised.conf);
  };
}
