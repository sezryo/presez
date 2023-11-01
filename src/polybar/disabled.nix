{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "polybar" "disabled"

{
  runtime.control.polybar.disabled = lib.mkDefault true;
}
