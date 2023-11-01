{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "thc-hydra" "basic"

{
  home.packages = [ pkgs.thc-hydra ];
}
