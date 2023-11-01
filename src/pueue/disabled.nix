{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "pueue" "disabled"

{
  runtime.control.pueue.disabled = lib.mkDefault true;
}
