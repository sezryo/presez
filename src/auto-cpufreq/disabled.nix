{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "auto-cpufreq" "disabled"

{
  runtime.control.auto-cpufreq.disabled = lib.mkDefault true;
}
