{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "babashka" "basic"

{
  home.packages = [ pkgs.babashka ];
}
