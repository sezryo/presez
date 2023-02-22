{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.gamescope ];
}