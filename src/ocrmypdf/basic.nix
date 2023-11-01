{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ocrmypdf" "basic"

{
  home.packages = [ pkgs.ocrmypdf ];
}
