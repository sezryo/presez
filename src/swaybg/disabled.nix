{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "swaybg" "disabled"

{
  runtime.control.swaybg.disabled = lib.mkDefault true;
}
