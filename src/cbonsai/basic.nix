{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "cbonsai" "basic"

{
  home.packages = [ pkgs.cbonsai ];
}
