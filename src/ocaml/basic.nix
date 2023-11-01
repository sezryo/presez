{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ocaml" "basic"

{
  home.packages = [ pkgs.ocaml ];
}
