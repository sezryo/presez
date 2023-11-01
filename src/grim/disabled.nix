{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "grim" "disabled"

{
  runtime.control.grim.disabled = lib.mkDefault true;
}
