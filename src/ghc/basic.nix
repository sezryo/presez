{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "ghc" "basic"

{
  home.packages = [ pkgs.ghc ];
}
