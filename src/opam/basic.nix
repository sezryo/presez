{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "opam" "basic"

{
  home.packages = [ pkgs.opam ];
}
