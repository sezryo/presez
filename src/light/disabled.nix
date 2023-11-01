{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "light" "disabled"

{
  runtime.control.light.disabled = lib.mkDefault true;
}
