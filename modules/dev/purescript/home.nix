{ pkgs, lib, ... }:

{
  home.packages = with pkgs;  [ purescript /*spago*/ dhall dhall-nix psc-package ];
}
