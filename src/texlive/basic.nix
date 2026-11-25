{ config, lib, pkgs, inputs, ... }:

{
  home.packages = [ pkgs.texliveFull ];
}
