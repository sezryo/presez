{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "mathematica" "basic"

{
  home.packages = [ pkgs.mathematica ];
}
