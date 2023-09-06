{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.pciutils ];
}