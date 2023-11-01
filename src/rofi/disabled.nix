{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "rofi" "disabled"

{
  runtime.control.rofi.disabled = lib.mkDefault true;
}
