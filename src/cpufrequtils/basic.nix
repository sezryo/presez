{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "cpufrequtils" "basic"

{
  environment.systemPackages = [ pkgs.cpufrequtils ];
}
