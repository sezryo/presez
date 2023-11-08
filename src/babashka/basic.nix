{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "babashka" "basic"

{
  home.packages = [ pkgs.babashka ];
}
