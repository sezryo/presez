{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "findutils" "basic"

{
  environment.systemPackages = [ pkgs.findutils ];
}
