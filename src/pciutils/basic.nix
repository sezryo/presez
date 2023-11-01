{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "pciutils" "basic"

{
  environment.systemPackages = [ pkgs.pciutils ];
}
