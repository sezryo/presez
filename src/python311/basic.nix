{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "python311" "basic"

{
  home.packages = [ pkgs.python311 ];
}
