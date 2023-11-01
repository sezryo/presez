{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "socat" "basic"

{
  home.packages = [ pkgs.socat ];
}
