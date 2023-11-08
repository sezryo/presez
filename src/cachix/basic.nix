{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "cachix" "basic"

{
  home.packages = [ pkgs.cachix ];
}
