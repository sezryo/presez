{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "spice" "basic"

{
  environment.systemPackages = [ pkgs.spice ];
}
