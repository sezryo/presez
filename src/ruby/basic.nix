{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ruby" "basic"

{
  home.packages = [ pkgs.ruby ];
}
