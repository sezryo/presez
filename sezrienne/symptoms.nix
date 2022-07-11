# Symptoms are significant signs

{ pkgs, lib, ... }:

{

  environment.systemPackages = with pkgs; [
    home-manager
    vim
    firefox
    wget
    git
    emacs
    emacsNativeComp
    pciutils
    binutils
    coreutils
    gnumake
    cron
  ];

}
