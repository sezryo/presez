{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "gojq" "basic"

{
  home.packages = [ pkgs.gojq ];
}
