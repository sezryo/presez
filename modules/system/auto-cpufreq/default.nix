{ pkgs, lib, ... }:

{
  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        turbo = "always";
      };
      battery = {
        governor = "conservative";
        turbo = "never";
      };
    };
  };
}
