{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./grub.nix
    ./kernel.nix
    ./tty.nix
  ];
}
