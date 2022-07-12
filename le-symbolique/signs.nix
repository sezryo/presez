{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [

  ## Haskell
  stack cabal-install ghc
  
  ## Topos
  agda coq

  ## Lisp
  racket clojure scheme48
  
  ## Rust
  rustc cargo

  ## Facade
  nodejs-18_x

  ## Minor
  ruby python311 clang

  ## Ergonomics
  tealdeer fd ripgrep exa

  ## Gismos
  htop neofetch radeontop

  ## Life
  tdesktop zoom-us mps-youtube qbittorrent
  
  ## Efficiency
  libreoffice okular calibre ocrmypdf gh

  ## Sensuality
  qemu ffmpeg

  ## Computational
  # wolfram-engine

  ];
}
