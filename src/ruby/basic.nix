{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "ruby" "basic"

{
  home.packages = [ pkgs.ruby ];
}
