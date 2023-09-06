{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.wget ];
}