{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "unicode-paracode" "basic"

{
  home.packages = [ pkgs.unicode-paracode ];
}
