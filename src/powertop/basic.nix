{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "powertop" "basic"

{
  environment.systemPackages = [ pkgs.powertop ];
}
