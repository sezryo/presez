{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "hyprland" "disabled"

{
  runtime.control.hyprland.disabled = lib.mkDefault true;
}
