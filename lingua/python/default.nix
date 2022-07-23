{ pkgs, lib, ... }:

{
  home.packages = with pkgs;  [ python311 ];
}
