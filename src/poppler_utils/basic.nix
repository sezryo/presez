{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "poppler_utils" "basic"

{
  home.packages = [ pkgs.poppler_utils ];
}
