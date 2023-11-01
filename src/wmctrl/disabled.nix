{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "wmctrl" "disabled"

{
  runtime.control.wmctrl.disabled = lib.mkDefault true;
}
