{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "xdotool" "disabled"

{
  runtime.control.xdotool.disabled = lib.mkDefault true;
}
