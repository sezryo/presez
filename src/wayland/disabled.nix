{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "wayland" "disabled"

{
  runtime.control.wayland.disabled = lib.mkDefault true;
}
