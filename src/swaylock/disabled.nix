{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "swaylock" "disabled"

{
  runtime.control.swaylock.disabled = lib.mkDefault true;
}
