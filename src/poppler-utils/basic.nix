{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "poppler-utils" "basic"

{
  home.packages = [ pkgs.poppler-utils ];
}
