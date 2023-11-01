{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "powertop" "disabled"

{
  runtime.control.powertop.disabled = lib.mkDefault true;
}
