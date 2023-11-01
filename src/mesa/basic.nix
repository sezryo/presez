{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "mesa" "basic"

{
  home.packages = [ pkgs.mesa ];
}
