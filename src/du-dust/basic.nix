{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "du-dust" "basic"

{
  home.packages = [ pkgs.du-dust ];
}
