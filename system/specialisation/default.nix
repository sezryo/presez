{ config, pkgs, lib, ... }:

{
  imports = [
    ./vfio.nix
    ./eco.nix
    ./non-specialised.nix
  ];

  specialisation."VFIO".configuration = {
    system.nixos.tags = [ "with-vfio" ];
    vfio.enable = true;
  };

  specialisation."ECO".configuration = {
    system.nixos.tags = [ "low-energy" ];
    eco.enable = true;
  };
}
