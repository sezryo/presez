{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "poppler_utils" "basic"

{
  home.packages = [ pkgs.poppler_utils ];
}
