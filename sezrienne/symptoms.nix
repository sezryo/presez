# Symptoms are significant signs

{ pkgs, lib, ... }:

{

  environment.systemPackages = with pkgs; [
    home-manager
    vim  
    firefox
    wget
    git
    pciutils
    binutils
    coreutils
    gnumake
    cron
  ];

}
