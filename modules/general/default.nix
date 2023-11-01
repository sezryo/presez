{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./core.nix
    ./firefox.nix
    ./gaming.nix
    ./maths.nix
    ./pdf.nix
    ./productivity.nix
    ./social.nix
    ./streaming.nix
    ./system.nix
    ./terminal.nix
  ];
}
