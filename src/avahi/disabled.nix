{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "avahi" "disabled"

{
  runtime.control.avahi.disabled = lib.mkDefault true;
}
