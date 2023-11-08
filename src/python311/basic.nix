{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "python311" "basic"

{
  home.packages = [ pkgs.python311 ];
}
