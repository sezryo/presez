{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [ scheme48 ];
}
