{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "unicode-paracode" "basic"

{
  home.packages = [ pkgs.unicode-paracode ];
}
