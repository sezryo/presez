{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./media.nix
    ./monitor.nix
    ./printing.nix
    ./udisk.nix
    ./virtualisation.nix
  ];
}
