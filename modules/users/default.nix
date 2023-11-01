{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ./dotfiles.nix
    ./home.nix
    ./users.nix
  ];
}
