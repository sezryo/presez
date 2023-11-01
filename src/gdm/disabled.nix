{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "gdm" "disabled"

{
  runtime.control.gdm.disabled = lib.mkDefault true;
}
