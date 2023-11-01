{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "unzip" "basic"

{
  home.packages = [ pkgs.unzip ];
}
