{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "wezterm" "disabled"

{
  runtime.control.wezterm.disabled = lib.mkDefault true;
}
