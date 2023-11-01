{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "sqlite" "basic"

{
  home.packages = [ pkgs.sqlite ];
}
