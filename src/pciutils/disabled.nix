{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "pciutils" "disabled"

{
  runtime.control.pciutils.disabled = lib.mkDefault true;
}
