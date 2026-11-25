{ config, lib, pkgs, inputs, ... }:

{
  home.packages = [ pkgs.rocqPackages.coq ];
}
