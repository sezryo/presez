{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "virt-manager" "basic"

{
  home.packages = [ pkgs.virt-manager ];
}
