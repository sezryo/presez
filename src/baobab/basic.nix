{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "baobab" "basic"

{
  home.packages = [ pkgs.baobab ];
}
