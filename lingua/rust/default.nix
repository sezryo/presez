{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [ rustc cargo ];
}
