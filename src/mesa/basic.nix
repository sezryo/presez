{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "mesa" "basic"

{
  home.packages = [ pkgs.mesa ];
}
