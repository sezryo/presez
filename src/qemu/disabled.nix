{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "qemu" "disabled"

{
  runtime.control.qemu.disabled = lib.mkDefault true;
}
