{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "flatpak" "disabled"

{
  runtime.control.flatpak.disabled = lib.mkDefault true;
}
