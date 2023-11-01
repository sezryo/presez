{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "sd" "basic"

{
  home.packages = [ pkgs.sd ];
}
