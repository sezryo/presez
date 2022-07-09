{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [

  ## Haskell
  stack cabal-install ghc
  
  ## Topos
  agda coq

  ## Lisp
  emacs racket clojure scheme48 
  
  ## Rust
  rustc cargo

  ## Facade
  nodejs-18_x

  ## Minor
  ruby python311 clang

  ## Ergonomics
  tealdeer fd ripgrep exa

  ## Gismo
  htop neofetch radeontop

  ## Life
  tdesktop zoom-us mps-youtube qbittorrent
  
  ## Efficiency
  libreoffice okular calibre ocrmypdf gh

  ## Computational
  # wolfram-engine

  ];
}
