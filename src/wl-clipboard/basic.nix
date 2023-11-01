{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "wl-clipboard" "basic"

{
  home.packages = [ pkgs.wl-clipboard ];
}
