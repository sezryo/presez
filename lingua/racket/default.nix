{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [ racket ];
}
