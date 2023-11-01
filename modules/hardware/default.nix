{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./cpu.nix
    ./ga402rk.nix
    # ./ga402xv.nix
    ./gpu.nix
    ./hdd.nix
    ./power.nix
    ./ssd.nix
    ./vfio.nix
  ];
}
