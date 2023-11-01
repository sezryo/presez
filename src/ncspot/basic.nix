{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ncspot" "basic"

{
  home.packages = [ pkgs.ncspot ];
}
