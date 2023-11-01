{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "psc-package" "basic"

{
  home.packages = [ pkgs.psc-package ];
}
