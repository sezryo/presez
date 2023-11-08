{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "ocaml" "basic"

{
  home.packages = [ pkgs.ocaml ];
}
