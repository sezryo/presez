{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "lm_sensors" "disabled"

{
  runtime.control.lm_sensors.disabled = lib.mkDefault true;
}
