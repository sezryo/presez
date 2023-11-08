{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "du-dust" "basic"

{
  home.packages = [ pkgs.du-dust ];
}
