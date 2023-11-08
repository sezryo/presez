{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "mathematica" "basic"

{
  home.packages = [ pkgs.mathematica ];
}
