{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "cabal-install" "basic"

{
  home.packages = [ pkgs.cabal-install ];
}
