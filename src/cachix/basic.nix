{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "cachix" "basic"

{
  home.packages = [ pkgs.cachix ];
}
