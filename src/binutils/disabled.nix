{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "binutils" "disabled"

{
  runtime.control.binutils.disabled = lib.mkDefault true;
}
