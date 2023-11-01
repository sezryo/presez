{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gnome" "disabled"

{
  runtime.control.gnome.disabled = lib.mkDefault true;
}
