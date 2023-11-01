{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "powertop" "basic"

{
  environment.systemPackages = [ pkgs.powertop ];
}
