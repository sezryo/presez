{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "thc-hydra" "basic"

{
  home.packages = [ pkgs.thc-hydra ];
}
