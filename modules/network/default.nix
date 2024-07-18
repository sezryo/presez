{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./nm.nix
    ./proxy.nix
    ./ssh.nix
    ./wireless.nix
    ./usb.nix
  ];
}
