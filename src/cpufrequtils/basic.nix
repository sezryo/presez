{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "cpufrequtils" "basic"

{
  environment.systemPackages = [ pkgs.cpufrequtils ];
}
