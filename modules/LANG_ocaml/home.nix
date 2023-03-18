{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    opam
    ocaml
    ocamlPackages.merlin
    ocamlPackages.utop
  ];
}
