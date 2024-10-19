{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./cpu.nix
    ./ga402rk.nix
    # ./ga402xv.nix
    ./x1nano2.nix
    ./gpu.nix
    ./hdd.nix
    ./power.nix
    ./ssd.nix
    ./vfio.nix
  ];
}
