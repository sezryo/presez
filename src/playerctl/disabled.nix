{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "playerctl" "disabled"

{
  runtime.control.playerctl.disabled = lib.mkDefault true;
}
