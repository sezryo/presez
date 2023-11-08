{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "psc-package" "basic"

{
  home.packages = [ pkgs.psc-package ];
}
