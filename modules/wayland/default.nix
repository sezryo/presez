{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.wayland ];
}