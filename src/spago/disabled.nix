{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "spago" "disabled"

{
  runtime.control.spago.disabled = lib.mkDefault true;
}
