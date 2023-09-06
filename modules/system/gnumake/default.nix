{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.gnumake ];
}