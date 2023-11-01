{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "purescript" "basic"

{
  home.packages = [ pkgs.purescript ];
}
