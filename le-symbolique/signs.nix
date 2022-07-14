{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [

  ## Command line tools
  # All described in ./incarnation.nix, mostly Rust used

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

  ## Monitors
  bottom neofetch radeontop conky

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
