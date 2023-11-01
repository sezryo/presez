{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "cpufrequtils" "disabled"

{
  runtime.control.cpufrequtils.disabled = lib.mkDefault true;
}
