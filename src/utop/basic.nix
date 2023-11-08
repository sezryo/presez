{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "utop" "basic"

{
  home.packages = [ pkgs.ocamlPackages.utop ];
}
