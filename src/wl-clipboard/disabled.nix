{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "wl-clipboard" "disabled"

{
  runtime.control.wl-clipboard.disabled = lib.mkDefault true;
}
