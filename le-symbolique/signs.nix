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
  tealdeer fd ripgrep exa trash-cli

  ## Monitors
  htop neofetch radeontop conky

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
