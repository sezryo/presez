{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "mixxx" "basic"

{
  home.packages = [ pkgs.mixxx ];
}
