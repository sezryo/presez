{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "opam" "basic"

{
  home.packages = [ pkgs.opam ];
}
