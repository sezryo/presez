{ config, lib, pkgs, inputs, ... }:

lib.mine.mkIfProfile config.modules.singleton "nushell" "disabled"

{
  runtime.control.nu.disabled = lib.mkDefault true;
}
