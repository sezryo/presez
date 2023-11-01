{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "dolphin" "disabled"

{
  runtime.control.dolphin.disabled = lib.mkDefault true;
}
