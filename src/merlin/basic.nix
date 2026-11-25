{ config, lib, pkgs, inputs, ... }:

{
  home.packages = [ pkgs.ocamlPackages.merlin ];
}
