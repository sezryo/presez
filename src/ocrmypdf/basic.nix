{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "ocrmypdf" "basic"

{
  home.packages = [ pkgs.ocrmypdf ];
}
