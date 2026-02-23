{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "localsend" "basic"

{
  home.packages = [ pkgs.localsend ];
}
