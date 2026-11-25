{ config, lib, pkgs, inputs, ... }:

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
