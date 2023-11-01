{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "brightnessctl" "disabled"

{
  runtime.control.brightnessctl.disabled = lib.mkDefault true;
}
