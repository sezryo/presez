{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.wmctrl ];
}