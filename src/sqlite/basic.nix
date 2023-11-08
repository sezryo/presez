{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "sqlite" "basic"

{
  home.packages = [ pkgs.sqlite ];
}
