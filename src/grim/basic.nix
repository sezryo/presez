{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "grim" "basic"

{
  home.packages = [ pkgs.grim ];
}
