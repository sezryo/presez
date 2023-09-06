{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.findutils ];
}