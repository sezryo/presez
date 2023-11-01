{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "udisks" "disabled"

{
  runtime.control.udisks.disabled = lib.mkDefault true;
}
