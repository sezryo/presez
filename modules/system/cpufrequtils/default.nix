{ pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.cpufrequtils ];
}