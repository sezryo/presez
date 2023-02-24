{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.pcre ];
}