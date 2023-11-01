{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "pcscd" "disabled"

{
  runtime.control.pcscd.disabled = lib.mkDefault true;
}
