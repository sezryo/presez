{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gnome-tweaks" "disabled"

{
  runtime.control.gnome-tweaks.disabled = lib.mkDefault true;
}
