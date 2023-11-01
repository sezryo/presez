{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gamescope" "basic"

{
  environment.systemPackages = [ pkgs.gamescope ];
}
