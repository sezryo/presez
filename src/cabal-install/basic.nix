{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "cabal-install" "basic"

{
  home.packages = [ pkgs.cabal-install ];
}
