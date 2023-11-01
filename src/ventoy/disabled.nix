{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "ventoy" "disabled"

{
  runtime.control.ventoy.disabled = lib.mkDefault true;
}
