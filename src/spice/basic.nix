{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "spice" "basic"

{
  environment.systemPackages = [ pkgs.spice ];
}
