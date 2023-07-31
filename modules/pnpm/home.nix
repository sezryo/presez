{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.nodePackages_latest.pnpm ];
}
