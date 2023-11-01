{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./encryption.nix
    ./kali.nix
    ./tpm.nix
    ./u2f.nix
  ];
}
