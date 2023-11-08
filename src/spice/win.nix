{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "spice" "win"

{
  environment.systemPackages = [ pkgs.win-spice ];
}
