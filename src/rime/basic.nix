{ config, pkgs, lib, ... }:

{
  home.packages = [ pkgs.rime-cli pkgs.rime-data ];
}
