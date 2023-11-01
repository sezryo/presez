{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gojq" "basic"

{
  home.packages = [ pkgs.gojq ];
}
