{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "scheme48" "basic"

{
  home.packages = [ pkgs.scheme48 ];
}
