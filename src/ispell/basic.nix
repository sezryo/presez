{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ispell" "basic"

{
  home.packages = [ pkgs.ispell ];
}
