{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [ nixfmt ];
}