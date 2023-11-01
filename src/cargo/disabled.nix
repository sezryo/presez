{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "cargo" "disabled"

{
  runtime.control.cargo.disabled = lib.mkDefault true;
}
