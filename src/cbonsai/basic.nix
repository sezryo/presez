{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "cbonsai" "basic"

{
  home.packages = [ pkgs.cbonsai ];
}
