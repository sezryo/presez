{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "asusd" "disabled"

{
  runtime.control.asusd.disabled = lib.mkDefault true;
}
