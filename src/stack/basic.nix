{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "stack" "basic"

{
  home.packages = [ pkgs.stack ];
}
