{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "utop" "basic"

{
  home.packages = [ pkgs.ocamlPackages.utop ];
}
