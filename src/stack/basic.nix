{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "stack" "basic"

{
  home.packages = [ pkgs.stack ];
}
