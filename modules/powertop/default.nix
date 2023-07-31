{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.powertop ];
}