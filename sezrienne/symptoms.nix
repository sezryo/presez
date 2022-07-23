# Symptoms are significant signs

{ pkgs, lib, ... }:

{

  environment.systemPackages = with pkgs; [
    home-manager
    vim
    wget
    pciutils
    binutils
    coreutils
    nixfmt
    gnumake
    cron
  ];

}
