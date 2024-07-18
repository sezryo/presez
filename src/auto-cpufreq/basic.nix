{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules "auto-cpufreq" "basic"

{
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "schedutil";
        turbo = "auto";
      };
      battery = {
        governor = "conservative";
        turbo = "never";
      };
    };
  };
}
