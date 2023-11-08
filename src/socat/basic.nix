{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "socat" "basic"

{
  home.packages = [ pkgs.socat ];
}
