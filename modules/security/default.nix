{ pkgs, config, lib, inputs, ... }:

{
  security.sudo.wheelNeedsPassword = lib.mkDefault false;
  imports = [
    ./encryption.nix
    ./kali.nix
    ./tpm.nix
    ./u2f.nix
  ];
}
