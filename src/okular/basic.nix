{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "okular" "basic"

{
  home.packages = [ pkgs.okular ];
}
