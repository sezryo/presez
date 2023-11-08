{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "wl-clipboard" "basic"

{
  home.packages = [ pkgs.wl-clipboard ];
}
