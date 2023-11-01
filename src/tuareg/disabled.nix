{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "tuareg" "disabled"

{
  runtime.control.tuareg.disabled = lib.mkDefault true;
}
