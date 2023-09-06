{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.coreutils ];
}