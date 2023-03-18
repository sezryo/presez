{ pkgs, lib, ... }:

{
  home.packages = with pkgs;  [ stack cabal-install ghc ];
}
