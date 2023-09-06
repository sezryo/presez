{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.vim ];
}