{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "hyfetch" "disabled"

{
  runtime.control.hyfetch.disabled = lib.mkDefault true;
}
