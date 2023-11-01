{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "nitrogen" "disabled"

{
  runtime.control.nitrogen.disabled = lib.mkDefault true;
}
