{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.xdotool ];
}