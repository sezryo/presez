{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "virt-manager" "disabled"

{
  runtime.control.virt-manager.disabled = lib.mkDefault true;
}
