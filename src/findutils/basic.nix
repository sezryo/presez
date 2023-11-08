{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "findutils" "basic"

{
  environment.systemPackages = [ pkgs.findutils ];
}
