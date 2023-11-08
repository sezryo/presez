{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "pciutils" "basic"

{
  environment.systemPackages = [ pkgs.pciutils ];
}
