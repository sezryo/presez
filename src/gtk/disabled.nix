{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gtk" "disabled"

{
  runtime.control.gtk.disabled = lib.mkDefault true;
}
