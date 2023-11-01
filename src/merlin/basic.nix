{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "merlin" "basic"

{
  home.packages = [ pkgs.ocamlPackages.merlin ];
}
