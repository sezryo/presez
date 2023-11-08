{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "virt-manager" "basic"

{
  home.packages = [ pkgs.virt-manager ];
}
