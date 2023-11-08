{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "baobab" "basic"

{
  home.packages = [ pkgs.baobab ];
}
