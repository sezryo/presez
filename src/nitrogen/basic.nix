{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "nitrogen" "basic"

{
  environment.systemPackages = [ pkgs.nitrogen ];
}
