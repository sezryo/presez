{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gnome-control-center" "disabled"

{
  runtime.control.gnome-control-center.disabled = lib.mkDefault true;
}
