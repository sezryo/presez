{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.chromium ];
}