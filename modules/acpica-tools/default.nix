{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.acpica-tools ];
}