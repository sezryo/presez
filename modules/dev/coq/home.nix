{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [ coq ];
}
