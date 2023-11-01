{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ghc" "basic"

{
  home.packages = [ pkgs.ghc ];
}
