{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [ gcc cmake ];
}