{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "upower" "disabled"

{
  runtime.control.upower.disabled = lib.mkDefault true;
}
