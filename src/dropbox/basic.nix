{ config, pkgs, lib, ... }:

{
  home.packages = [ pkgs.dropbox-cli ];
}
