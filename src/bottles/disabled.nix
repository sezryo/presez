{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "bottles" "disabled"

{
  runtime.control.bottles.disabled = lib.mkDefault true;
}
