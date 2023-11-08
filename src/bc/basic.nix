{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "bc" "basic"

{
  home.packages = [ pkgs.bc ];
}
