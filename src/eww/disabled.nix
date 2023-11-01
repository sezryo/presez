{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "eww" "disabled"

{
  runtime.control.eww.disabled = lib.mkDefault true;
}
