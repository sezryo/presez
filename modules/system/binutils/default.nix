{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.binutils ];
}