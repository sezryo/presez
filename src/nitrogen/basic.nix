{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "nitrogen" "basic"

{
  environment.systemPackages = [ pkgs.nitrogen ];
}
