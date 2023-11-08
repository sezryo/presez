{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "purescript" "basic"

{
  home.packages = [ pkgs.purescript ];
}
