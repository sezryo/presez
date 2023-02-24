{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.findutils ];
}