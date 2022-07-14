{ config, lib, pkgs, ... }:

{
  programs.nushell = {
    enable = true;
    configFile.source = ./incarnation-via-crucis/config.nu;
    envFile.source = ./incarnation-via-crucis/env.nu;
  };

  home.packages = with pkgs; [

    # Shell interface
    starship nushell

    # Non-rust command line tools
    busybox trash-cli

    # Rust command line tools
    bat lsd fd ripgrep tealdeer zoxide fzf procs du-dust grex tokei delta sd

  ];
}
