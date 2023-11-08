{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "merlin" "basic"

{
  home.packages = [ pkgs.ocamlPackages.merlin ];
}
