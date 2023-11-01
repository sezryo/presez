{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "spice" "win"

{
  environment.systemPackages = [ pkgs.win-spice ];
}
