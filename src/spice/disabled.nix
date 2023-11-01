{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "spice" "disabled"

{
  runtime.control.spice.disabled = lib.mkDefault true;
}
