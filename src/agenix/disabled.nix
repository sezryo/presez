{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "agenix" "disabled"

{
  runtime.control.agenix.disabled = lib.mkDefault true;
}
