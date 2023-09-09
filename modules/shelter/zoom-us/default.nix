{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.zoom-us ];
  home.file.".config/zoomus.conf".source = ./myZoomus.conf;
}
