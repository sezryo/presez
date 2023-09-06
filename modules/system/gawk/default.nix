{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.gawk ];
}