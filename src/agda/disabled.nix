{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "agda" "disabled"

{
  runtime.control.agda.disabled = lib.mkDefault true;
}
