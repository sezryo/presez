{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "gamescope" "basic"

{
  environment.systemPackages = [ pkgs.gamescope ];
}
