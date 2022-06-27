{ config, pkgs, lib, ... }:

{
  imports =
    [ 
      ./existenz.nix
      ./dasein.nix
      ../le-real/intersubjectivity.nix
      ../le-real/in-der-welt-sein.nix
      ../le-imaginare/societe/spectacle.nix
    ];

  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  
  users.users.sezrienne = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; 
  };

  environment.systemPackages = with pkgs; [
  
    ## Essntials
    home-manager firefox wget vim emacs vscode
    ## Contribution
    git gh
    ## Utils
    pciutils binutils coreutils gnumake
    
    ## Haskell
    stack cabal-install ghc agda
    ## Pure Languages
    agda coq racket clojure 
    ## Impure Languages
    ruby python311 nodejs-18_x rustc cargo clang
    
    ## Gismo
    neofetch tealdeer tree cron ripgrep fd
    ## Monitor
    htop radeontop
    ## Life
    tdesktop zoom-us mps-youtube qbittorrent
    ##  Efficiency
    libreoffice okular calibre ocrmypdf
    ##  Computational
    # wolfram-engine
    
    ## Shell
    fish starship fzf
    
  ];

  
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; 
    dedicatedServer.openFirewall = true;
  }; 
  
  system.stateVersion = "22.05";

}

